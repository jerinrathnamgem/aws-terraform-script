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

variable "task_env_vars" {
  type = list(list(object(
    {
      name  = string,
      value = string
    }
  )))
  description = "List of key-value pair of environment variables for ecs task definition"
  default     = null # Reference: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KeyValuePair.html
  # default = [
  #  [
  #   {
  #     name  = "ENV1"
  #     value = "task1"
  #   },
  #   {
  #     name  = "ENV2"
  #     value = "task2"
  #   }
  # ]
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
  default     = null # Reference: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_EnvironmentFile.html
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

variable "task_commands" {
  type        = list(string)
  description = "List of The commands that's passed to the container."
  default     = null
}

variable "task_credential_specs" {
  type        = list(string)
  description = "A list of ARNs in SSM or Amazon S3 to a credential spec (CredSpec) file that configures the container for Active Directory authentication. We recommend that you use this parameter instead of the dockerSecurityOptions. The maximum number of ARNs is 1."
  default     = null
}

variable "task_entry_points" {
  type        = list(string)
  description = "List of The entry points that's passed to the container"
  default     = null
}

variable "task_health_check" {
  type        = map(any)
  description = "The container health check command and associated configuration parameters for the container."
  default     = null
}

variable "task_host_name" {
  type        = string
  description = "The hostname to use for your container."
  default     = null
}

variable "task_mount_point" {
  type        = list(map(any))
  description = "The mount points for data volumes in your container."
  default     = null
}

variable "task_volume" {
  type        = list(any)
  description = "Data volumes to mount from efs or docker or windows"
  default     = null
}

variable "task_volumes_from" {
  type        = list(map(any))
  description = "Data volumes to mount from another container"
  default     = null
}