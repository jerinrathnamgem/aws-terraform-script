variable "name" {
  type        = string
  description = "Name for your Infrastructure"
  default     = ""
}

variable "region" {
  type        = string
  description = "Region of the Infrastructure"
}

variable "port" {
  type        = number
  description = "Port number for the application"
}

variable "subnet_id" {
  type        = string
  description = "ID of the Subnet"
  default     = null
}

variable "sg_id" {
  type        = string
  description = "ID of the Security Group"
  default     = null
}

variable "amiID" {
  type        = string
  description = "Provide the AMI ID for EC2 Instance"
  default     = ""
}

variable "create_eip" {
  type        = bool
  description = "Whether to create Elastic IP or not"
  default     = true
}

variable "private_key_name" {
  type        = string
  description = "Enter the name of the Key-Pair"
  default     = null
}

variable "private_key_file" {
  type        = string
  description = "Enter the name of the Key-Pair"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "Provide the type of the EC2 Instance"
  default     = null
}

variable "volume_termination" {
  type        = bool
  description = "Select the volume of the instance should be delete or not"
  default     = true
}

variable "volume_size" {
  type        = number
  description = "Size of the Ec2 root volume"
}

variable "volume_encryption" {
  type        = bool
  description = "Whether to encypt you ec2 root volume"
  default     = true
}