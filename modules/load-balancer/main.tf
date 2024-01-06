############## DATA SOURCE ##################

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

locals {
  count       = length(var.host_names) > 0 ? length(var.host_names) : length(var.host_paths) > 0 ? length(var.host_paths) : length(var.host_names_and_paths) > 0 ? length(var.host_names_and_paths) : 0
  account_id  = data.aws_caller_identity.this.account_id
  region      = data.aws_region.this.name
  http_action = var.certificate_arn != ""
}

##################################### LOAD BALANCER #####################################

resource "aws_lb" "this" {
  count = var.do_not_create_alb ? 0 : 1

  name                             = var.load_balancer_name
  internal                         = var.private_load_balancer
  load_balancer_type               = var.load_balancer_type
  security_groups                  = var.security_groups
  subnets                          = var.subnet_ids
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  enable_waf_fail_open             = var.enable_waf_fail_open
  idle_timeout                     = var.lb_idle_timeout
  ip_address_type                  = var.ip_address_type
  preserve_host_header             = var.preserve_host_header

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [1] : []

    content {
      bucket  = var.access_logs.bucket_id
      prefix  = lookup(access_logs.value, "prefix", null)
      enabled = lookup(access_logs.value, "enabled", null)
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping != null ? var.subnet_mapping : []

    content {
      subnet_id            = var.subnet_mapping.subnet_id
      private_ipv4_address = lookup(subnet_mapping.value, "private_ipv4_address", null)
      ipv6_address         = lookup(subnet_mapping.value, "ipv6_address", null)
      allocation_id        = lookup(subnet_mapping.value, "allocation_id", null)
    }
  }

  tags = merge(
    {
      "Name" = var.load_balancer_name
    },
    var.tags
  )

}

######################## LISTENER GROUP FOR HTTP ####################################

resource "aws_lb_listener" "http" {
  count = var.create_listeners ? 1 : 0

  load_balancer_arn = var.do_not_create_alb == false ? one(aws_lb.this[*].arn) : var.load_balancer_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = local.http_action ? "redirect" : "forward"
    target_group_arn = local.http_action ? null : aws_lb_target_group.this[0].arn

    dynamic "redirect" {
      for_each = local.http_action ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_lb_listener_rule" "http" {
  count = local.http_action ? 0 : (length(var.host_names) > 0 ? length(var.host_names) : length(var.host_paths) > 0 ? length(var.host_paths) : (length(var.host_names_and_paths) > 0 ? length(var.host_names_and_paths) : 0))

  priority     = count.index + 1
  listener_arn = var.create_listeners ? one(aws_lb_listener.http[*].arn) : var.http_listener_arn

  action {
    type             = local.http_action ? "redirect" : "forward"
    target_group_arn = local.http_action ? null : aws_lb_target_group.this[count.index + 1].arn

    dynamic "redirect" {
      for_each = local.http_action ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.host_names) > 0 ? [1] : []

    content {
      host_header {
        values = [var.host_names[count.index]]
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.host_paths) > 0 ? [1] : []

    content {
      path_pattern {
        values = [var.host_paths[count.index]]
      }

    }
  }

  # host and path conditions
  dynamic "condition" {
    for_each = length(var.host_names_and_paths) > 0 ? var.host_names_and_paths[count.index] : {}

    content {
      host_header {
        values = [condition.key]
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.host_names_and_paths) > 0 ? var.host_names_and_paths[count.index] : {}

    content {
      path_pattern {
        values = [condition.value]
      }

    }
  }

}

################################## LISTENER CREATION HTTPS #####################################################

resource "aws_lb_listener" "https" {
  count = local.http_action ? 1 : 0

  load_balancer_arn = var.do_not_create_alb == false ? one(aws_lb.this[*].arn) : var.load_balancer_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}

resource "aws_lb_listener_rule" "https" {
  count = local.http_action ? (length(var.host_names) > 0 ? length(var.host_names) : length(var.host_paths) > 0 ? length(var.host_paths) : (length(var.host_names_and_paths) > 0 ? length(var.host_names_and_paths) : 0)) : 0

  priority     = count.index + 1
  listener_arn = var.https_listener_arn == null ? one(aws_lb_listener.https[*].arn) : var.https_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[count.index + 1].arn
  }

  dynamic "condition" {
    for_each = length(var.host_names) > 0 ? [1] : []

    content {
      host_header {
        values = [var.host_names[count.index]]
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.host_paths) > 0 ? [1] : []

    content {
      path_pattern {
        values = [var.host_paths[count.index]]
      }
    }
  }

  # host and path conditions
  dynamic "condition" {
    for_each = length(var.host_names_and_paths) > 0 ? var.host_names_and_paths[count.index] : {}

    content {
      host_header {
        values = [condition.key]
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.host_names_and_paths) > 0 ? var.host_names_and_paths[count.index] : {}

    content {
      path_pattern {
        values = [condition.value]
      }

    }
  }
}

####################### TARGET GROUP #############################

resource "aws_lb_target_group" "this" {
  count = length(var.names)

  name        = lower(var.names[count.index])
  port        = length(var.target_group_ports) > 1 ? var.target_group_ports[count.index] : var.target_group_ports[0]
  protocol    = length(var.protocol) > 1 ? var.protocol[count.index] : var.protocol[0]
  target_type = length(var.target_type) > 1 ? var.target_type[count.index] : var.target_type[0]
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = var.names[count.index]
    },
    var.tags
  )

  health_check {
    healthy_threshold   = var.healthy_threshold
    interval            = var.health_check_interval
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
    timeout             = var.health_check_timeout
    path                = length(var.health_check_paths) > 1 ? var.health_check_paths[count.index] : var.health_check_paths[0]
    unhealthy_threshold = var.unhealthy_threshold
    port                = length(var.ports) > 1 ? var.ports[count.index] : var.ports[0]
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count = var.create_ec2_deployment ? length(var.names) : 0

  target_group_arn = aws_lb_target_group.this[count.index].arn
  target_id        = var.instance_id
  port             = length(var.ports) > 1 ? var.ports[count.index] : var.ports[0]
}