
variable "create_security_group" {
  type        = bool
  description = "Whether to create security group"
  default     = true
}

variable "security_group_id" {
  type        = string
  description = "Id of a Security group. Only need when 'security_group_id' is set to false"
  default     = null
}

variable "create_egress_rule" {
  description = "Whether to egress rule for security group created"
  type        = bool
  default     = true
}

variable "myip_ssh" {
  description = "List of IP address for ssh connection. If no SSH needed, just leave it"
  type        = list(string)
  default     = null
}

variable "name" {
  description = "Name to be used on Security group created"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = null
}

variable "vpc_description" {
  type        = string
  description = "Description for VPC"
  default     = "VPC created by terraform"
}

variable "vpc_id" {
  description = "ID of vpc. Need only if you want to create in a custom vpc"
  type        = string
  default     = null
}

variable "tcp_ports" {
  description = "List of TCP ports in Security group"
  type        = list(number)
  default     = []
}

variable "udp_ports" {
  description = "List of UDP ports in Security group"
  type        = list(number)
  default     = []
}

variable "egress_port" {
  type        = list(number)
  description = "List of Ports for egress rule"
  default     = [0]
}

variable "egress_source_security_group_ids" {
  type        = list(string)
  description = "List of source security ids for egress rule"
  default     = []
}

variable "ingress_tcp_source_security_group_ids" {
  type        = list(string)
  description = "List of source security ids for ingress tcp rule"
  default     = []
}

variable "ingress_udp_source_security_group_ids" {
  type        = list(string)
  description = "List of source security ids for ingress udp rule"
  default     = []
}

variable "egress_cidr_blocks" {
  type        = list(string)
  description = "List of the cidr range blocks for security group"
  default     = ["0.0.0.0/0"]
}

variable "tcp_cidr_blocks" {
  type        = list(string)
  description = "List of the cidr range blocks for security group"
  default     = ["0.0.0.0/0"]
}

variable "udp_cidr_blocks" {
  type        = list(string)
  description = "List of the cidr range blocks for security group"
  default     = ["0.0.0.0/0"]
}