resource "aws_eks_cluster" "cluster" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  kubernetes_network_config {
    ip_family = "ipv4"
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    security_group_ids      = [aws_security_group.service-sg.id]
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled" = "true"
    Name                                   = var.name
    "alpha.eksctl.io/cluster-name"         = var.name
  }
}