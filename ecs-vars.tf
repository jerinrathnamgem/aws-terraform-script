variable "ecs_service_names" {
  type        = list(string)
  description = "List of Names for ECS services"
  default     = ["Node-App-1"]
}

variable "ecs_ports" {
  type        = list(number)
  description = "List of Port numbers for the application in ECS"
  default     = [3000]
}

variable "create_cluster" {
  type        = bool
  description = "Whether the ECS or EKS cluster needs to be create or not. If 'false' It will use existing ECS cluster"
  default     = true
}

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
  default     = "cluster-name"
}

variable "ignore_changes" {
  type        = bool
  description = "Whehter to ignore changes configuration should be apply"
  default     = true
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether the public ip for ECS service should be created"
  default     = true
}

variable "cw_logs_retention_in_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0"
  default     = 60
}

variable "task_cpu" {
  type        = list(number)
  description = "List of CPU for task definition. If a single value is same for all services, then provide one value is enough"
  default     = [256]
}

variable "task_memory" {
  type        = list(number)
  description = "List of Memory for task definition. If a single value is same for all services, then provide one value is enough"
  default     = [512]
}

variable "ecs_subnet_ids" {
  type        = list(string)
  description = "list of subnet ids for ECS service"
  default     = null
}

variable "task_max_capacity" {
  type        = list(number)
  description = "List of maximum capacity number for task. If a single value is same for all services, then provide one value is enough"
  default     = [5]
}

variable "task_min_capacity" {
  type        = list(number)
  description = "List of minimum capacity number for task. If a single value is same for all services, then provide one value is enough"
  default     = [1]
}

variable "task_env_vars" {
  type = list(list(object(
    {
      name  = string,
      value = string
    }
  )))
  description = "List of key-value pair of environment variables for ecs task definition"
  default     = [] # Reference: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KeyValuePair.html
  # default = [
  #   [
  #     {
  #       name  = "ENV1"
  #       value = "task1"
  #     },
  #     {
  #       name  = "ENV2"
  #       value = "task1"
  #     }
  #   ]
  # ]
}

variable "task_env_files" {
  type = list(list(object(
    {
      type  = string,
      value = string
    }
  )))
  description = "A list of files containing the environment variables to pass to a container."
  default     = [] # Reference: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_EnvironmentFile.html
}

variable "task_commands" {
  type        = list(list(string))
  description = "List of The commands that's passed to the container."
  default     = []
}

variable "task_credential_specs" {
  type        = list(list(string))
  description = "A list of ARNs in SSM or Amazon S3 to a credential spec (CredSpec) file that configures the container for Active Directory authentication. We recommend that you use this parameter instead of the dockerSecurityOptions. The maximum number of ARNs is 1."
  default     = []
}

variable "task_entry_points" {
  type        = list(list(string))
  description = "List of The entry points that's passed to the container"
  default     = []
}

variable "task_health_check" {
  type        = list(map(any))
  description = "The container health check command and associated configuration parameters for the container."
  default     = []
}

variable "task_host_name" {
  type        = list(string)
  description = "The hostname to use for your container."
  default     = []
}

variable "task_volumes_from" {
  type        = list(list(map(any)))
  description = "Data volumes to mount from another container"
  default     = []
}

variable "task_ephemeral_storage" {
  type        = list(number)
  description = "The total amount, in GiB, of ephemeral storage to set for the task. The minimum supported value is 21 GiB and the maximum supported value is 200 GiB."
  default     = []
}

variable "container_paths" {
  type        = list(string)
  description = "List of volume path in ECS task containers. Should be same as the vaue of the variable task_mount_path --> containerPath"
  default     = []
}

variable "container_images" {
  type        = list(string)
  description = "List of images for task definition"
  default     = []
}

variable "image_tags" {
  type        = list(string)
  description = "List of ECR image tags. If tags are 'latest' for all the images just leave it default. If a single value is same for all services, then provide one value is enough"
  default     = ["latest"]
}

# EFS Storage

variable "create_efs" {
  type        = bool
  description = "Whether to create efs storage for ECS"
  default     = false
}


variable "efs_encrypted" {
  type        = bool
  description = "Whether the EFS storage c=should be encrypted"
  default     = true
}

variable "efs_kms_id" {
  type        = string
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, encrypted needs to be set to true."
  default     = null
}

variable "efs_throughput_mode" {
  type        = string
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with throughput_mode set to provisioned."
  default     = "bursting"
}

variable "efs_performance_mode" {
  type        = string
  description = "The file system performance mode. Can be either 'generalPurpose' or 'maxIO'"
  default     = "generalPurpose"
}

variable "efs_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for EFS. If default VPC using, Leave it as empty"
  default     = []
}