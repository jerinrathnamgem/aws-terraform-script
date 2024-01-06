
############## DATA SOURCE ##################

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

locals {
  count        = length(var.name)
  account_id   = data.aws_caller_identity.this.account_id
  region       = var.region == null ? data.aws_region.this.name : var.region
  cluster_arn  = var.create_cluster ? aws_ecs_cluster.this[0].arn : "arn:aws:ecs:${local.region}:${local.account_id}:cluster/${var.cluster_name}"
  cluster_name = var.create_cluster ? aws_ecs_cluster.this[0].name : var.cluster_name
}

#################### ECS CLUSTER #########################

resource "aws_ecs_cluster" "this" {

  count = var.create_cluster ? 1 : 0

  name = var.cluster_name

  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.tags
  )
}

###################### ECS SERVICE ########################

resource "aws_ecs_service" "this" {

  count = var.ignore_changes ? 0 : local.count

  name            = var.name[count.index]
  cluster         = local.cluster_arn
  task_definition = aws_ecs_task_definition.this[count.index].arn
  desired_count   = length(var.task_desired_count) > 1 ? var.task_desired_count[count.index] : var.task_desired_count[0]
  launch_type     = var.task_launch_type

  depends_on = [aws_ecs_task_definition.this]

  deployment_controller {
    type = var.deployment_controller
  }

  dynamic "load_balancer" {

    for_each = var.load_balancing ? [1] : []

    content {
      target_group_arn = var.target_group_names != null ? "arn:aws:elasticloadbalancing:${local.region}:${local.account_id}:targetgroup/${var.target_group_names[count.index]}" : var.target_group_arns[count.index]
      container_name   = var.container_name != null ? var.container_name[count.index] : var.name[count.index]
      container_port   = length(var.port) > 1 ? var.port[count.index] : var.port[0]
    }
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [length(var.security_groups) > 1 ? var.security_groups[count.index] : var.security_groups[0]]
    assign_public_ip = var.assign_public_ip
  }

  tags = merge(
    {
      "Name" = var.name[count.index]
    },
    var.tags
  )
}

resource "aws_ecs_service" "ignore_changes" {

  count = var.ignore_changes ? local.count : 0

  name            = var.name[count.index]
  cluster         = local.cluster_arn
  task_definition = aws_ecs_task_definition.ignore_changes[count.index].arn
  desired_count   = length(var.task_desired_count) > 1 ? var.task_desired_count[count.index] : var.task_desired_count[0]
  launch_type     = var.task_launch_type

  depends_on = [aws_ecs_task_definition.this]

  deployment_controller {
    type = var.deployment_controller
  }

  dynamic "load_balancer" {

    for_each = var.load_balancing ? [1] : []

    content {
      target_group_arn = var.target_group_names != null ? "arn:aws:elasticloadbalancing:${local.region}:${local.account_id}:targetgroup/${var.target_group_names[count.index]}" : var.target_group_arns[count.index]
      container_name   = var.container_name != null ? var.container_name[count.index] : var.name[count.index]
      container_port   = length(var.port) > 1 ? var.port[count.index] : var.port[0]
    }
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [length(var.security_groups) > 1 ? var.security_groups[count.index] : var.security_groups[0]]
    assign_public_ip = var.assign_public_ip
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      network_configuration,
      launch_type,
      deployment_controller,
      load_balancer,
    ]
  }

  tags = merge(
    {
      "Name" = var.name[count.index]
    },
    var.tags
  )
}

#################### ECS TASK DEFINITION #######################

resource "aws_ecs_task_definition" "this" {

  count = var.ignore_changes ? 0 : local.count

  family                   = var.name[count.index]
  cpu                      = length(var.task_cpu) > 1 ? var.task_cpu[count.index] : var.task_cpu[0]
  memory                   = length(var.task_memory) > 1 ? var.task_memory[count.index] : var.task_memory[0]
  network_mode             = var.network_mode
  requires_compatibilities = [var.task_launch_type]

  container_definitions = jsonencode(
    [
      {
        name      = var.container_name != null ? var.container_name[count.index] : var.name[count.index]
        image     = var.create_ecr_repository ? "${aws_ecr_repository.this[count.index].repository_url}:${length(var.image_tags) > 1 ? var.image_tags[count.index] : var.image_tags[0]}" : "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.ecr_repo_names[count.index]}:${length(var.image_tags) > 1 ? var.image_tags[count.index] : var.image_tags[0]}"
        cpu       = length(var.container_cpu) == 0 ? null : length(var.container_cpu) > 1 ? var.container_cpu[count.index] : var.container_cpu[0]
        memory    = length(var.container_memory) == 0 ? null : length(var.container_memory) > 1 ? var.container_memory[count.index] : var.container_memory[0]
        essential = true

        command          = var.task_commands
        entrypoint       = var.task_entry_points
        environmentFiles = var.task_env_files
        healthCheck      = var.task_health_check
        hostname         = var.task_host_name
        mountPoints      = var.task_mount_point
        volumesFrom      = var.task_volumes_from
        volume           = var.task_volume

        logConfiguration = {
          logDriver = var.container_log_driver
          options = {
            awslogs-region        = local.region
            awslogs-group         = var.create_cloudwatch_log_group ? "/ecs/${var.name[count.index]}" : var.cloudwatch_log_group_names[count.index]
            awslogs-stream-prefix = "ecs"
          }
        }

        environment = var.task_env_vars

        portMappings = [
          {
            containerPort = length(var.port) > 1 ? var.port[count.index] : var.port[0]
            hostPort      = length(var.host_port) > 0 ? (length(var.host_port) > 1 ? var.host_port[count.index] : var.host_port[0]) : length(var.port) > 1 ? var.port[count.index] : var.port[0]
          }
        ]
      }
    ]
  )

  execution_role_arn = var.ecs_task_role_name != null ? "arn:aws:iam::${local.account_id}:role/${var.ecs_task_role_name}" : aws_iam_role.this[0].arn
  task_role_arn      = var.ecs_task_role_name != null ? "arn:aws:iam::${local.account_id}:role/${var.ecs_task_role_name}" : aws_iam_role.this[0].arn

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

  tags = merge(
    {
      "Name" = var.name[count.index]
    },
    var.tags
  )
}

resource "aws_ecs_task_definition" "ignore_changes" {

  count = var.ignore_changes ? local.count : 0

  family                   = var.name[count.index]
  cpu                      = length(var.task_cpu) > 1 ? var.task_cpu[count.index] : var.task_cpu[0]
  memory                   = length(var.task_memory) > 1 ? var.task_memory[count.index] : var.task_memory[0]
  network_mode             = var.network_mode
  requires_compatibilities = [var.task_launch_type]

  container_definitions = jsonencode(
    [
      {
        name      = var.container_name != null ? var.container_name[count.index] : var.name[count.index]
        image     = var.create_ecr_repository ? "${aws_ecr_repository.this[count.index].repository_url}:${length(var.image_tags) > 1 ? var.image_tags[count.index] : var.image_tags[0]}" : "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.ecr_repo_names[count.index]}:${length(var.image_tags) > 1 ? var.image_tags[count.index] : var.image_tags[0]}"
        cpu       = length(var.container_cpu) == 0 ? null : length(var.container_cpu) > 1 ? var.container_cpu[count.index] : var.container_cpu[0]
        memory    = length(var.container_memory) == 0 ? null : length(var.container_memory) > 1 ? var.container_memory[count.index] : var.container_memory[0]
        essential = true

        command          = var.task_commands
        entrypoint       = var.task_entry_points
        environmentFiles = var.task_env_files
        healthCheck      = var.task_health_check
        hostname         = var.task_host_name
        mountPoints      = var.task_mount_point
        volumesFrom      = var.task_volumes_from
        volume           = var.task_volume

        logConfiguration = {
          logDriver = var.container_log_driver
          options = {
            awslogs-region        = local.region
            awslogs-group         = var.create_cloudwatch_log_group ? "/ecs/${var.name[count.index]}" : var.cloudwatch_log_group_names[count.index]
            awslogs-stream-prefix = "ecs"
          }
        }

        environment = var.task_env_vars

        portMappings = [
          {
            containerPort = length(var.port) > 1 ? var.port[count.index] : var.port[0]
            hostPort      = length(var.host_port) > 0 ? (length(var.host_port) > 1 ? var.host_port[count.index] : var.host_port[0]) : length(var.port) > 1 ? var.port[count.index] : var.port[0]
          }
        ]
      }
    ]
  )

  execution_role_arn = var.ecs_task_role_name != null ? "arn:aws:iam::${local.account_id}:role/${var.ecs_task_role_name}" : aws_iam_role.this[0].arn
  task_role_arn      = var.ecs_task_role_name != null ? "arn:aws:iam::${local.account_id}:role/${var.ecs_task_role_name}" : aws_iam_role.this[0].arn

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

  lifecycle {
    ignore_changes = [
      container_definitions,
      runtime_platform,
      execution_role_arn,
      task_role_arn,
      family,
      cpu,
      memory,
      network_mode,
      requires_compatibilities
    ]
  }

  tags = merge(
    {
      "Name" = var.name[count.index]
    },
    var.tags
  )
}

###################### AUTOSCALING TARGET ############################

resource "aws_appautoscaling_target" "this" {

  count = var.enable_autoscaling ? local.count : 0

  max_capacity       = length(var.task_max_capacity) > 1 ? var.task_max_capacity[count.index] : var.task_max_capacity[0]
  min_capacity       = length(var.task_min_capacity) > 1 ? var.task_min_capacity[count.index] : var.task_min_capacity[0]
  resource_id        = "service/${local.cluster_name}/${var.ignore_changes ? aws_ecs_service.ignore_changes[count.index].name : aws_ecs_service.this[count.index].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#################### AUTOSCALING POLICY ############################

resource "aws_appautoscaling_policy" "this" {

  count = var.enable_autoscaling ? local.count : 0

  name               = "${var.name[count.index]}-CpuUtilization"
  policy_type        = var.autoscaling_policy_type
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  dynamic "target_tracking_scaling_policy_configuration" {

    for_each = var.autoscaling_policy_type == "TargetTrackingScaling" ? [1] : []

    content {
      predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
      }

      target_value       = length(var.cpu_utilization_target_value) > 1 ? var.cpu_utilization_target_value[count.index] : var.cpu_utilization_target_value[0]
      scale_in_cooldown  = var.autoscaling_scale_in_cooldown
      scale_out_cooldown = var.autoscaling_scale_out_cooldown
    }
  }

  dynamic "step_scaling_policy_configuration" {

    for_each = var.autoscaling_policy_type == "StepScaling" ? [1] : []

    content {
      adjustment_type          = var.autoscaling_adjustment_type
      cooldown                 = var.autoscaling_cooldown
      metric_aggregation_type  = var.autoscaling_metric_aggregation_type
      min_adjustment_magnitude = var.autoscaling_min_adjustment_magnitude

      dynamic "step_adjustment" {

        for_each = var.autoscaling_step_adjustment == null ? [] : var.autoscaling_step_adjustment

        content {
          metric_interval_lower_bound = step_adjustment.value.lower_bound
          metric_interval_upper_bound = step_adjustment.value.upper_bound
          scaling_adjustment          = step_adjustment.value.scaling_adjustment
        }
      }
    }
  }
}

####################### ECR REPOSITORY #######################

resource "aws_ecr_repository" "this" {

  count = var.create_ecr_repository ? local.count : 0

  name                 = lower(var.name[count.index])
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    {
      "Name" = var.name[count.index]
    },
    var.tags
  )
}

resource "aws_ecr_lifecycle_policy" "this" {

  count = var.create_ecr_repository && var.enable_ecr_lifecycle ? local.count : 0

  repository = aws_ecr_repository.this[count.index].name

  policy = jsonencode(
    {
      rules = [
        {
          rulePriority = 1
          description  = "rule for remove untagged images"
          selection = {
            tagStatus   = "untagged"
            countType   = "sinceImagePushed"
            countUnit   = "days"
            countNumber = 1
          },
          action = {
            type = "expire"
          }
        },
        {
          rulePriority = 2
          description  = "rule for remove other old images"
          selection = {
            tagStatus   = "any"
            countType   = "imageCountMoreThan"
            countNumber = 25
          },
          action = {
            type = "expire"
          }
        }
      ]
    }
  )
}


##################### CLOUDWATCH LOG GROUP #################

resource "aws_cloudwatch_log_group" "this" {

  count = var.create_cloudwatch_log_group ? local.count : 0

  name              = "/ecs/${var.name[count.index]}"
  retention_in_days = var.cw_logs_retention_in_days

  tags = merge(
    {
      "Name" = var.name[count.index]
    },
    var.tags
  )
}

################## IAM ROLE #######################

resource "aws_iam_role" "this" {

  count = var.ecs_task_role_name == null ? 1 : 0

  name = "${var.name[0]}-ecs-role"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "sts:AssumeRole"
          ]
          Effect = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
        }
      ]
    }
  )
}

################# IAM POLICY ################

resource "aws_iam_role_policy" "this" {

  count = var.ecs_task_role_name == null ? 1 : 0

  name = "${var.name[0]}-ecs-policy"
  role = aws_iam_role.this[0].id

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
          ]
          Effect   = "Allow"
          Resource = var.create_ecr_repository ? aws_ecr_repository.this[*].arn : ["*"]
        },
        {
          Action = [
            "ecr:GetAuthorizationToken"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = var.create_cloudwatch_log_group ? concat(aws_cloudwatch_log_group.this[*].arn, formatlist("%s:*", aws_cloudwatch_log_group.this[*].arn)) : ["*"]
        }
      ]
    }
  )
}