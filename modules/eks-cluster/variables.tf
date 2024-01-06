variable "name" {
  type        = string
  description = "Name for clsuter and infrastructure"
}

variable "account_id" {
  type        = string
  description = "Account id number of this aws account"
}

variable "vpc_id" {
  type        = string
  description = "Id of the vpc"
}

variable "myip_ssh" {
  type        = list(string)
  description = "List of the Ip addresses for ssh connection with eks nodes"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of the Public and Private subnet Ids"
}

variable "private_key" {
  type        = string
  description = "Name of the key pair to connect with nodes"
}

variable "instance_types" {
  type        = list(string)
  description = "List of types of the Instances"
}

variable "ami_type" {
  type        = string
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid Values: AL2_x86_64 | AL2_x86_64_GPU | AL2_ARM_64 | CUSTOM | BOTTLEROCKET_ARM_64 | BOTTLEROCKET_x86_64 | BOTTLEROCKET_ARM_64_NVIDIA | BOTTLEROCKET_x86_64_NVIDIA | WINDOWS_CORE_2019_x86_64 | WINDOWS_FULL_2019_x86_64 | WINDOWS_CORE_2022_x86_64 | WINDOWS_FULL_2022_x86_64"
  default     = "AL2_x86_64"
}

variable "cluster_version" {
  type        = string
  description = "Version of EKS Cluster"
}

variable "node_subnet_ids" {
  type        = list(string)
  description = "List of the subnet Ids"
}

variable "launch_template_version" {
  type        = string
  description = "Version of the ec2 launch template"
  default     = "$Latest"
}

variable "delete_on_termination" {
  type        = bool
  description = "whether the root volume of the nodes should be delete or not when instance termination"
}

variable "volume_size" {
  type        = number
  description = "Size of the volume for each nodes"
  default     = 20
}

variable "max_size" {
  type        = number
  description = "maximun size of the nodes for autoscaling group"
}

variable "min_size" {
  type        = number
  description = "minimum size of the nodes for autoscaling group"
}

variable "desired_size" {
  type        = number
  description = "desired size of the nodes for autoscaling group"
}

variable "region" {
  type        = string
  description = "Name of the region"
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "List of EKS Cluster log types."
  default     = ["api", "audit", "authenticator"]
}

variable "cluster_endpoint_private_access" {
  type        = string
  description = "Whether the Amazon EKS private API server endpoint is enabled."
  default     = false
}

variable "cluster_endpoint_public_access" {
  type        = string
  description = "Whether the Amazon EKS public API server endpoint is enabled."
  default     = true
}