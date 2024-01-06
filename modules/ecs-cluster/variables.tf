variable "assign_public_ip" {
  type        = bool
  description = "Whether the public ip for service should be created"
  default     = true
}

variable "autoscaling_policy_type" {
  type        = string
  description = " Policy type. Valid values are StepScaling and TargetTrackingScaling"
  default     = "TargetTrackingScaling"
}

variable "autoscaling_scale_in_cooldown" {
  type        = number
  description = "Amount of time, in seconds, after a scale in activity completes before another scale in activity can start."
  default     = null
}

variable "autoscaling_scale_out_cooldown" {
  type        = number
  description = "Amount of time, in seconds, after a scale out activity completes before another scale out activity can start."
  default     = null
}

variable "autoscaling_adjustment_type" {
  type        = string
  description = "Whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity."
  default     = "PercentChangeInCapacity"
}

variable "autoscaling_cooldown" {
  type        = number
  description = "Amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
  default     = 120
}

variable "autoscaling_metric_aggregation_type" {
  type        = string
  description = "Aggregation type for the policy's metrics. Valid values are 'Minimum', 'Maximum', and 'Average'"
  default     = "Average"
}

variable "autoscaling_min_adjustment_magnitude" {
  type        = string
  description = "Minimum number to adjust your scalable dimension as a result of a scaling activity."
  default     = null
}

variable "autoscaling_step_adjustment" {
  type = list(
    object(
      {
        lower_bound        = number
        upper_bound        = number
        scaling_adjustment = number
      }
    )
  )
  description = "Set of adjustments that manage scaling."
  default     = null
}

variable "cloudwatch_log_group_names" {
  type        = list(string)
  description = "List of cloudwatch log group names. Only need if 'create_cloudwatch_log_group' is set to 'false'"
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "Name for the Cluster"
}

variable "container_cpu" {
  type        = list(number)
  description = "List of CPU for container definition. If a single value is same for all containers, then provide one value is enough"
  default     = []
}

variable "container_memory" {
  type        = list(number)
  description = "List of Memory for container definition. If a single value is same for all containers, then provide one value is enough"
  default     = []
}

variable "container_name" {
  type        = list(string)
  description = "List of the names for containers"
  default     = null
}

variable "container_log_driver" {
  type        = string
  description = "The log driver to use for the container."
  default     = "awslogs"
}

variable "cpu_architecture" {
  type        = string
  description = "CPU architecture for Task definition"
  default     = "X86_64"
}

variable "cpu_utilization_target_value" {
  type        = list(number)
  description = "List of avarage CPU utilization target values in percentage for services. If a single value is same for all services, then provide one value is enough"
  default     = [75]
}

variable "create_cloudwatch_log_group" {
  type        = bool
  description = "Whether cloudwatch log group needs to be create or not"
  default     = true
}

variable "create_cluster" {
  type        = bool
  description = "Whether ecs cluster needs to be create or not"
  default     = true
}

variable "create_ecr_repository" {
  type        = bool
  description = "Whether ecr repository needs to be create or not"
  default     = true
}

variable "cw_logs_retention_in_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0"
  default     = 30
}

variable "deployment_controller" {
  type        = string
  description = "Type of deployment in ecs"
  default     = "ECS"
}

variable "enable_ecr_lifecycle" {
  type        = bool
  description = "Whether to enable ECR Life Cycle Policy"
  default     = true
}

variable "enable_autoscaling" {
  type        = bool
  description = "Whether to enable Autoscaling for ECS Services"
  default     = true
}

variable "ecr_repo_names" {
  type        = list(string)
  description = "List of the names of ecr repositories. Only needed if 'create_ecr_repository' is set to 'false'"
  default     = null
}

variable "ecs_task_role_name" {
  type        = string
  description = "Name of ecs task iam role"
  default     = null
}

variable "host_port" {
  type        = list(number)
  description = "List of host ports"
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

variable "load_balancing" {
  type        = bool
  description = "Whether to attach loadbalancer with ecs services"
  default     = false
}

variable "name" {
  type        = list(string)
  description = "List of names for services"
}

variable "network_mode" {
  type        = string
  description = "Network mode for ecs task definition"
  default     = "awsvpc"
}

variable "operating_system_family" {
  type        = string
  description = "Name of an operating system for task definition"
  default     = "LINUX"
}

variable "port" {
  type        = list(number)
  description = "List of the ports for containers. If a single value is same for all services, then provide one value is enough"
  default     = [80]
}

variable "region" {
  type        = string
  description = "Region for infrastructure"
  default     = null
}

variable "security_groups" {
  type        = list(string)
  description = "List of IDs of security groups. If a single value is same for all services, then provide one value is enough"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of the Ids of subnets"
}

variable "tags" {
  type        = map(string)
  description = "Tags for your infrastructure"
  default     = {}
}

variable "task_commands" {
  type        = list(string)
  description = "List of The commands that's passed to the container."
  default     = null
}

variable "task_cpu" {
  type        = list(number)
  description = "List of CPU for task definition. If a single value is same for all services, then provide one value is enough"
  default     = [256]
}

variable "task_entry_points" {
  type        = list(string)
  description = "List of The entry points that's passed to the container"
  default     = null
}

variable "task_env_vars" {
  type        = list(map(string))
  description = "List of key-value pair of environment variables for ecs task definition"
  default     = null
}

variable "task_env_files" {
  type        = list(map(string))
  description = "A list of files containing the environment variables to pass to a container."
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

variable "task_memory" {
  type        = list(number)
  description = "List of Memory for task definition. If a single value is same for all services, then provide one value is enough"
  default     = [512]
}

variable "target_group_arns" {
  type        = list(string)
  description = "List of ARNs of target groups. This is need if target groups are created from another module"
  default     = null
}

variable "target_group_names" {
  type        = list(string)
  description = "List of Names of target groups. This is need if target groups are created via console"
  default     = null
}

variable "task_desired_count" {
  type        = list(number)
  description = "List of Desired count for task running in service. If a single value is same for all services, then provide one value is enough"
  default     = [1]
}

variable "task_launch_type" {
  type        = string
  description = "Launch type for service and task"
  default     = "FARGATE"
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

variable "ignore_changes" {
  type        = bool
  description = "Whehter to ignore changes configuration should be apply"
  default     = true
}