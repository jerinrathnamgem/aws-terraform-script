
resource "aws_security_group" "node-sg" {
  name        = "${var.name}-node-sg"
  description = "Communication between all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                             = "${var.name}-node-sg"
    "alpha.eksctl.io/nodegroup-name" = "${var.name}-ng"
    "alpha.eksctl.io/nodegroup-type" = "managed"
  }
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.myip_ssh
  security_group_id = aws_security_group.node-sg.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node-sg.id
}

resource "aws_security_group_rule" "cluster_inbound" {
  count             = 1
  type              = "ingress"
  from_port         = 1024
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node-sg.id
}

#############################################################################

resource "aws_security_group" "service-sg" {
  name        = "${var.name}-service-sg"
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                             = "${var.name}-service-sg"
    "alpha.eksctl.io/nodegroup-name" = "${var.name}-ng"
    "alpha.eksctl.io/nodegroup-type" = "managed"
  }
}

resource "aws_security_group_rule" "IngressNodeToDefaultClusterSG" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.nodegroup-sg.id
  security_group_id        = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id #aws_security_group.service-sg.id
}

resource "aws_security_group" "nodegroup-sg" {
  name        = "${var.name}-nodegroup-sg"
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                             = "${var.name}-nodegroup-sg"
    "alpha.eksctl.io/nodegroup-name" = "${var.name}-ng"
    "alpha.eksctl.io/nodegroup-type" = "managed"
  }
}

resource "aws_security_group_rule" "IngressDefaultClusterToNodeSG" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id #aws_security_group.service-sg.id
  security_group_id        = aws_security_group.nodegroup-sg.id
}
resource "aws_security_group_rule" "IngressInterNodeGroupSG" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.nodegroup-sg.id
  security_group_id        = aws_security_group.nodegroup-sg.id
}
