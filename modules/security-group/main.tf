
locals {
  ssh_port = 22
}

######################## SECURITY GROUP ##############################

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = var.name
  description = var.vpc_description
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

########################### SECURITY GROUP RULES for EGRESS ####################################

resource "aws_security_group_rule" "egress" {
  count = var.create_egress_rule ? length(var.egress_port) - length(var.egress_source_security_group_ids) : 0

  type              = "egress"
  from_port         = var.egress_source_security_group_ids != [] ? var.egress_port[count.index + length(var.egress_source_security_group_ids)] : var.egress_port[count.index]
  to_port           = var.egress_source_security_group_ids != [] ? var.egress_port[count.index + length(var.egress_source_security_group_ids)] : var.egress_port[count.index]
  protocol          = var.egress_port[0] != 0 ? "tcp" : "-1"
  cidr_blocks       = var.egress_cidr_blocks
  security_group_id = var.create_security_group ? aws_security_group.this[0].id : var.security_group_id
}

resource "aws_security_group_rule" "egress-source-sg" {
  count = var.create_egress_rule && var.egress_source_security_group_ids != [] ? length(var.egress_source_security_group_ids) : 0

  type                     = "egress"
  from_port                = var.egress_port[count.index]
  to_port                  = var.egress_port[count.index]
  protocol                 = var.egress_port[0] != 0 ? "tcp" : "-1"
  source_security_group_id = var.egress_source_security_group_ids[count.index]
  security_group_id        = var.create_security_group ? aws_security_group.this[0].id : var.security_group_id
}

########################## SECURITY GROUP RULES for SSH INGRESS ####################################

resource "aws_security_group_rule" "ssh_ingress" {
  count = var.myip_ssh != null ? 1 : 0

  type              = "ingress"
  from_port         = local.ssh_port
  to_port           = local.ssh_port
  protocol          = "tcp"
  cidr_blocks       = var.myip_ssh
  security_group_id = var.create_security_group ? aws_security_group.this[0].id : var.security_group_id
}

############################ SECURITY GROUP RULES for TCP INGRESS ####################################

resource "aws_security_group_rule" "ingress" {
  count = var.tcp_ports != [] ? length(var.tcp_ports) - length(var.ingress_tcp_source_security_group_ids) : 0

  type              = "ingress"
  from_port         = var.ingress_tcp_source_security_group_ids != [] ? var.tcp_ports[count.index + length(var.ingress_tcp_source_security_group_ids)] : var.tcp_ports[count.index]
  to_port           = var.ingress_tcp_source_security_group_ids != [] ? var.tcp_ports[count.index + length(var.ingress_tcp_source_security_group_ids)] : var.tcp_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = var.tcp_cidr_blocks
  security_group_id = var.create_security_group ? aws_security_group.this[0].id : var.security_group_id
}

resource "aws_security_group_rule" "source-sg-tcp" {
  count = var.ingress_tcp_source_security_group_ids != [] && var.tcp_ports != [] ? length(var.ingress_tcp_source_security_group_ids) : 0

  type                     = "ingress"
  from_port                = var.tcp_ports[count.index]
  to_port                  = var.tcp_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = var.ingress_tcp_source_security_group_ids[count.index]
  security_group_id        = var.create_security_group ? aws_security_group.this[0].id : var.security_group_id
}

############################### SECURITY GROUP RULES for UDP INGRESS ####################################

resource "aws_security_group_rule" "udp" {
  count = var.udp_ports != [] ? length(var.udp_ports) - length(var.ingress_udp_source_security_group_ids) : 0

  type              = "ingress"
  from_port         = var.ingress_udp_source_security_group_ids != [] ? var.udp_ports[count.index + length(var.ingress_udp_source_security_group_ids)] : var.udp_ports[count.index]
  to_port           = var.ingress_udp_source_security_group_ids != [] ? var.udp_ports[count.index + length(var.ingress_udp_source_security_group_ids)] : var.udp_ports[count.index]
  protocol          = "udp"
  cidr_blocks       = var.udp_cidr_blocks
  security_group_id = var.create_security_group ? aws_security_group.this[0].id : var.security_group_id
}

resource "aws_security_group_rule" "source-sg-udp" {
  count = var.ingress_udp_source_security_group_ids != [] && var.udp_ports != [] ? length(var.ingress_udp_source_security_group_ids) : 0

  type                     = "ingress"
  from_port                = var.udp_ports[count.index]
  to_port                  = var.udp_ports[count.index]
  protocol                 = "udp"
  source_security_group_id = var.ingress_udp_source_security_group_ids[count.index]
  security_group_id        = var.create_security_group ? aws_security_group.this[0].id : var.security_group_id
}