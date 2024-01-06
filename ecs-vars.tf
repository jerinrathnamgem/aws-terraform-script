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