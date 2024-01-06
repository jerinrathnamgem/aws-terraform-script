# S3 BUCKET

output "s3_bucket_arn" {
  description = "ARN of the Code Pipeline S3 bucket"
  value       = one(aws_s3_bucket.this[*].arn)
}

output "s3_bucket_id" {
  description = "ID of the COde Pipeline S3 bucket"
  value       = one(aws_s3_bucket.this[*].id)
}

# CODE BUILD PROJECT

output "build_project_arn" {
  description = "ARN of the Code Builf Project"
  value       = one(aws_codebuild_project.this[*].arn)
}

output "build_logs_public_url" {
  value       = one(aws_codebuild_project.this[*].public_project_alias)
  description = "The project identifier used with the public build APIs."
}

# CODE DEPLOY APP

output "deploy_app_arn" {
  description = "ARN of the Code Deploy Application"
  value       = one(aws_codedeploy_app.this[*].arn)
}

output "deploy_app_id" {
  description = "Application ID of the Code Deploy Application"
  value       = one(aws_codedeploy_app.this[*].application_id)
}

output "deploy_group_arn" {
  description = "ARN of the Code Deployment Group"
  value       = one(aws_codedeploy_deployment_group.this[*].arn)
}

output "deployment_group_id" {
  description = "The ID of the CodeDeploy deployment group."
  value       = one(aws_codedeploy_deployment_group.this[*].deployment_group_id)
}

output "deploy_group_id" {
  description = "Application name and deployment group name."
  value       = one(aws_codedeploy_deployment_group.this[*].id)
}

# CODE PIPELINE

output "code_pipeline_id" {
  description = "ID of the Code Pipeline"
  value       = var.backend_deployment ? aws_codepipeline.this[0].id : var.ec2_deployment ? aws_codepipeline.this_1[0].id : aws_codepipeline.this_2[0].id
}

output "code_pipeline_arn" {
  description = "ARN of the Code Pipeline"
  value       = var.backend_deployment ? aws_codepipeline.this[0].arn : var.ec2_deployment ? aws_codepipeline.this_1[0].arn : aws_codepipeline.this_2[0].arn
}