output "build_logs_public_url" {
  description = "List of Public Build URLs of Code Build projects"
  value       = !var.aws_deployment ? null : var.create_ec2_deployment ? null : (!var.create_pipeline ? null : zipmap(var.create_ecs_deployment ? var.ecs_service_names : var.eks_pipeline_names , formatlist("https://${var.region}.codebuild.aws.amazon.com/project/%s", var.create_ecs_deployment ? module.ecs-pipeline[*].build_logs_public_url : module.eks-pipeline[*].build_logs_public_url)))
}

output "dns_name" {
  description = "Domain Name of the Load Balancer"
  value       = one(module.load-balancer[*].dns_name)
}

output "GCP_docker_image" {
  description = "docker image URI of the GCP deployment application"
  value       = var.aws_deployment ? null : "${local.image}:latest"
}