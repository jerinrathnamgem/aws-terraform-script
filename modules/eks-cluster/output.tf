
output "endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_name" {
  description = "Name of the EKS Cluster"
  value       = aws_eks_cluster.cluster.id
}

output "cluster_arn" {
  description = "ARN of the EKS Cluster"
  value       = aws_eks_cluster.cluster.arn
}

output "cluster_certificate_authority_data" {
  description = "Certificate Authority data of the EKS Cluster"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_oidc_url" {
  description = "Oidc provider url of the EKS Cluster"
  value       = aws_eks_cluster.cluster.identity[0].oidc
}

output "asg_name" {
  value       = aws_eks_node_group.ng.resources[0].autoscaling_groups[0].name
  description = "Name of the autoscaling group"
}

output "kubectl_role_arn" {
  description = "ARN of the kubectl iam role"
  value       = one(aws_iam_role.kubectl_role[*].arn)
}

output "ng_role_arn" {
  description = "ARN of the Node Group iam role"
  value       = aws_iam_role.node_group.arn
}
