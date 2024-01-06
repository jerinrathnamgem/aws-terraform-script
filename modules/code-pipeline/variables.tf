variable "env_vars" {
  type        = map(string)
  description = "key and value pair of environment variables for code build project"
  default     = null
}

variable "ec2_tag_filters" {
  type        = map(string)
  description = "Key and value pairs of ec2 instance tags for code deployment group"
  default     = null
}

variable "name" {
  type        = string
  description = "Name for this infrastructure"
}

variable "create_s3_bucket" {
  type        = bool
  description = "Whehter the S3 bucket for codepipeline should be create"
  default     = false
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the pipeline s3 bucket."
  default     = null
}

variable "backend_deployment" {
  type        = bool
  description = "For the Backend deployment"
  default     = false
}

variable "ecs_deployment" {
  type        = bool
  description = "For the ECS deployment"
  default     = true
}

variable "ec2_deployment" {
  type        = bool
  description = "For the EC2 deployment"
  default     = false
}

variable "source_provider" {
  type        = string
  description = "Name of the source provider for the code pipeline"
  default     = "GitHub"
}

variable "source_owner" {
  type        = string
  description = "Owner of the source provider for the code pipeline"
  default     = "ThirdParty"
}

variable "github_oauth_token" {
  type        = string
  description = "GitHub OAuth Token with permissions to access private repositories"
  default     = null
}

variable "repo_owner" {
  type        = string
  description = "GitHub Organization or Username"
  default     = null
}

variable "repo_name" {
  type        = string
  description = "GitHub repository name of the application to be built and deployed to ECS"
  default     = null
}

variable "branch" {
  type        = string
  description = "Branch of the GitHub repository, _e.g._ `master`"
  default     = null
}

variable "github_webhook_events" {
  type        = list(string)
  description = "A list of events which should trigger the webhook. See a list of [available events](https://developer.github.com/v3/activity/events/types/)"
  default     = ["push"]
}

variable "repo_id" {
  type        = string
  description = "ID of the source code repository"
  default     = null
}

variable "repo_branch_name" {
  type        = string
  description = "Name of the source code repo branch"
  default     = null
}

variable "connection_arn" {
  type        = string
  description = "ARN of the code star connection"
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "Name of the ECS Cluster name"
  default     = null
}

variable "service_name" {
  type        = string
  description = "Name of the ECS Service name"
  default     = null
}

variable "privileged_mode" {
  type        = bool
  description = "Whether to enable running the Docker daemon inside a Docker container."
  default     = true
}

variable "image_identifier" {
  type        = string
  description = "Docker image to use for this build project."
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
}

variable "tags" {
  type        = map(string)
  description = "Tags for this infrastructure"
  default     = {}
}

variable "create_deploy_group" {
  type        = bool
  description = "Whether the deployment group shoul be create or not"
  default     = true
}

variable "codedeploy_app" {
  type        = string
  description = "Name of the code deployment app. Is needed if 'create_deploy_group' is set to 'false'"
  default     = null
}

variable "deployment_group" {
  type        = string
  description = "Name of the code deployment group. Is needed if 'create_deploy_group' is set to 'false'"
  default     = null
}

variable "project_visibility" {
  type        = string
  description = "Specifies the visibility of the project's builds. Possible values are: PUBLIC_READ and PRIVATE. Default value is PRIVATE."
  default     = "PRIVATE"
}

variable "build_spec" {
  type        = string
  description = "Path of the build spec file"
  default     = "buildspec-ecs.yml"
}

variable "compute_type" {
  type        = string
  description = "Type or aize of the server for code build project"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_container_type" {
  type        = string
  description = "Type of build environment to use for related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER."
  default     = "LINUX_CONTAINER"
}

variable "secret_id" {
  type        = string
  description = "ARN of the secrets manager"
  default     = null
}

variable "deployment_timeout" {
  type        = number
  description = "The Amazon ECS deployment action timeout in minutes. The timeout is configurable up to the maximum default timeout for this action."
  default     = 10
}