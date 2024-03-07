output "AWS_build_logs_public_url" {
  description = "List of Public Build URLs of Code Build projects"
  value       = !var.aws_deployment ? null : var.create_ec2_deployment ? null : (!var.create_pipeline ? null : zipmap(var.create_ecs_deployment ? var.ecs_service_names : var.eks_pipeline_names, formatlist("https://${var.region}.codebuild.aws.amazon.com/project/%s", var.create_ecs_deployment ? module.ecs-pipeline[*].build_logs_public_url : module.eks-pipeline[*].build_logs_public_url)))
}

output "AWS_lb_dns_name" {
  description = "Domain Name of the Load Balancer"
  value       = one(module.load-balancer[*].dns_name)
}

output "GCP_docker_image" {
  description = "docker image URI of the GCP deployment application"
  value       = var.aws_deployment ? null : zipmap(var.gcp_pipeline_names, formatlist("${local.image}/%s:latest", var.gcp_pipeline_names))
}

output "GCP_loadbalancer_ip" {
  description = "Name ad IP address of the Ingress Loadbalancer"
  value       = zipmap(["${var.gcp_name}-web-ip"], data.google_compute_global_address.ingress[*].address)
}