resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.name}-${random_integer.rand.result}"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.node_subnet_ids
  instance_types  = var.instance_types
  ami_type        = var.ami_type

  labels = {
    "alpha.eksctl.io/cluster-name"   = aws_eks_cluster.cluster.name,
    "alpha.eksctl.io/nodegroup-name" = "${var.name}-${random_integer.rand.result}"
  }

  launch_template {
    id      = aws_launch_template.template.id
    version = var.launch_template_version
  }

  lifecycle {
    # create_before_destroy = true
    ignore_changes = [
      launch_template[0].version,
      scaling_config[0].desired_size
    ]

  }

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    "alpha.eksctl.io/nodegroup-name" = "${var.name}-${random_integer.rand.result}"
    "alpha.eksctl.io/nodegroup-type" = "managed"
    "alpha.eksctl.io/cluster-name"   = aws_eks_cluster.cluster.name
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}

resource "random_integer" "rand" {
  min = 20000
  max = 99999
}

###################################### CONFIG MAP ################################################

# resource "kubernetes_config_map_v1_data" "aws-auth" {

#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   force = true

#   data = {
#     mapRoles = yamlencode(
#       [
#         {
#           rolearn  = aws_iam_role.kubectl_role[0].arn
#           username = "build"
#           groups   = ["system:masters"]
#         },
#         {
#           rolearn  = aws_iam_role.node_group.arn
#           username = "system:node:{{EC2PrivateDNSName}}"
#           groups   = ["system:bootstrappers", "system:nodes"]
#         }
#       ]
#     )
#   }

#   depends_on = [
#     aws_eks_node_group.ng
#   ]
# }