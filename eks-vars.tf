variable "eks_node_type" {
  type        = string
  description = "Provide the type of the EKS cluster nodes"
  default     = "t3.medium"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name for EKS cluster"
  default     = "eks-cluster-name"
}

variable "cluster_version" {
  type        = string
  description = "Version of the EKS cluster"
  default     = "1.28"
}

variable "node_ami_type" {
  type        = string
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid Values: AL2_x86_64 | AL2_x86_64_GPU | AL2_ARM_64 | CUSTOM | BOTTLEROCKET_ARM_64 | BOTTLEROCKET_x86_64 | BOTTLEROCKET_ARM_64_NVIDIA | BOTTLEROCKET_x86_64_NVIDIA | WINDOWS_CORE_2019_x86_64 | WINDOWS_FULL_2019_x86_64 | WINDOWS_CORE_2022_x86_64 | WINDOWS_FULL_2022_x86_64"
  default     = "AL2_x86_64"
}

variable "node_volume_size" {
  type        = number
  description = "Size of the EKS cluster nodes"
  default     = 30
}

variable "node_volume_termination" {
  type        = bool
  description = "Select the volume of EKS cluster nodes should be delete or not"
  default     = false
}

variable "node_max_size" {
  type        = number
  description = "maximun size of the nodes for autoscaling group"
  default     = 5
}

variable "node_min_size" {
  type        = number
  description = "minimum size of the nodes for autoscaling group"
  default     = 2
}

variable "node_desired_size" {
  type        = number
  description = "desired size of the nodes for autoscaling group"
  default     = 2
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

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "List of EKS Cluster log types. Enter 'null' for disable logs"
  default     = ["api", "audit", "authenticator"]
}

variable "env_vars" {
  type        = map(any)
  description = "Map of environment variables for code build project"
  default     = {}
}

variable "eks_pipeline_names" {
  type        = list(string)
  description = "List of names for EKS pipelines. Leave it blank if no pipeline needs to be create"
  default     = []
}

variable "eks_subnet_ids" {
  type        = list(string)
  description = "list of subnet ids for EKS Cluster Control plane"
  default     = null
}

variable "eks_node_subnet_ids" {
  type        = list(string)
  description = "list of subnet ids for EKS Node group"
  default     = null
}