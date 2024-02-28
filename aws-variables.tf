######################################### MAIN ##############################################

variable "aws_deployment" {
  type        = bool
  description = "Whether to deploy resources in AWS cloud"
  default     = true # this will create resources in AWS
}

variable "access_key" {
  type        = string
  sensitive   = true
  description = "Enter the AWS Access Key ID"
  default     = null
}

variable "secret_key" {
  type        = string
  sensitive   = true
  description = "Enter the AWS Secret Access Key"
  default     = null
}

variable "region" {
  type        = string
  description = "Enter the region for your infrastructure"
  default     = "us-east-1"
}

variable "create_ecs_deployment" {
  type        = bool
  description = "For ECS deployment"
  default     = true
}

variable "create_ec2_deployment" {
  type        = bool
  description = "For EC2 deployment"
  default     = false
}

variable "create_eks_deployment" {
  type        = bool
  description = "For EKS deployment"
  default     = false
}

######################### VPC #######################################

variable "vpc_id" {
  type        = string
  description = "ID of the vpc"
  default     = "vpc-id"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "list of subnet ids for Load Balancer"
  default     = null
}

################################## CODE PIPELINE #############################################

variable "create_pipeline" {
  type        = bool
  description = "Whether to create pipeline or not"
  default     = true
}

variable "codebuild_compute_type" {
  type        = string
  description = "Type or aize of the server for code build project. Valid values: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_container_type" {
  type        = string
  description = "Type of build environment to use for related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER."
  default     = "LINUX_CONTAINER"
}

variable "image_identifier" {
  type        = string
  description = "Docker image to use for this build project."
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
}

variable "repo_ids" {
  type        = list(string)
  description = "List of IDs of the source code repository"
  default     = ["repo-id"]
}

variable "repo_branch_names" {
  type        = list(string)
  description = "List of Names of the source code repo branch"
  default     = ["main"]
}

variable "github_oauth_token" {
  type        = string
  description = "GitHub OAuth Token with permissions to access private repositories"
  default     = "ouath-token"
}

variable "repo_owner" {
  type        = string
  description = "GitHub Organization or Username"
  default     = "github-username"
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

variable "ecs_deployment_timeout" {
  type        = number
  description = "The Amazon ECS deployment action timeout in minutes. The timeout is configurable up to the maximum default timeout for this action."
  default     = 10
}

######################## LOAD BALANCER ################################

variable "load_balancer_name" {
  type        = string
  description = "Name for load balancer. if this value is 'null' Load Balancer won't be created."
  default     = null
}

variable "certificate_arn" {
  type        = string
  description = "Certificate arn of the domain for load balancer"
  default     = ""
}

variable "host_names" {
  type        = list(string)
  description = "List of names of domains. If you need to setup multiple domains, enter the domain names from the second applciations"
  default     = []
}

variable "host_paths" {
  type        = list(string)
  description = "List of paths of hosts. If ypu jave setup multiple paths, enter paths from the second applications"
  default     = []
}

variable "health_check_paths" {
  type        = list(string)
  description = "List of health check paths"
  default     = ["/"]
}

variable "health_check_timeout" {
  type        = number
  description = "Amount of time, in seconds, during which no response from a target means a failed health check."
  default     = 30
}

variable "health_check_interval" {
  type        = number
  description = "Approximate amount of time, in seconds, between health checks of an individual target"
  default     = 60
}

#################### ROUTE 53 #######################

variable "route53_zone_ids" {
  type        = list(string)
  description = "List of IDs of Route 53 Hosted zones. if same hosted zone for all sub domains single value is enough"
  default     = []
}

variable "route53_record_names" {
  type        = list(string)
  description = "List of subdomains for your applications"
  default     = []
}

variable "sns_topic_arn" {
  type        = string
  description = "Only need to Provide SNS ARN, if there is existing SNS topic"
  default     = null
}

variable "email_addresses" {
  type        = list(string)
  description = "List of Email address for code commit notification"
  default     = ["example@gmail.com"]
}

################## SECRETS MANAGER ###########################

variable "create_secrets_manager" {
  type        = bool
  description = "whether to create secrets manager or not"
  default     = true
}

variable "secret_name" {
  type        = string
  description = "Name for the secrets manager"
  default     = "secret-name"
}

variable "secrets_manager_arn" {
  type        = string
  description = "ARN of the secrets manager. If you have existing Secrets Manager, Provide the ARN here"
  default     = null
}

variable "docker_username" {
  type        = string
  description = "Username of the Docker hub registry"
}

variable "docker_password" {
  type        = string
  description = "Username of docker hub password"
}

variable "secrets_manager_kms_key_id" {
  type        = string
  description = "ARN or Id of the AWS KMS key to be used to encrypt the secret values in the versions stored in this secret"
  default     = null # Not needed if you use default KMS key
}

variable "kms_key_recovery_window_in_days" {
  type        = number
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret. This value can be 0 to force deletion without recovery or range from 7 to 30 days."
  default     = 30
}

################## EXTRA Values ######################

variable "connection_arn" {
  type        = string
  description = "ARN of the code star connection, Not needed"
  default     = null
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for codepipeline"
  default     = null
}

variable "create_s3_bucket" {
  type        = bool
  description = "Whether to create s3 bucket for pipeline"
  default     = true
}