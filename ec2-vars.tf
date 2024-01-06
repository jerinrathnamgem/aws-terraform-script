variable "ec2_name" {
  type        = string
  description = "Name for EC2 instance"
  default     = "Node-App-1"
}

variable "create_ec2_server" {
  type        = bool
  description = "whether to create EC2 instance"
  default     = true
}

variable "ami_id" {
  type        = string
  description = "Provide the AMI ID for EC2 Instance"
  default     = null
}

variable "create_eip" {
  type        = bool
  description = "Whether to create Elastic IP or not"
  default     = true
}

variable "ec2_port" {
  type        = number
  description = "Port number for the application in EC2"
  default     = 3000
}

variable "private_key_name" {
  type        = string
  description = "Enter the name of the Key-Pair"
  default     = null
}

variable "volume_encryption" {
  type        = bool
  description = "Whether to encypt you ec2 root volume"
  default     = true
}

variable "ssh_cidr_ips" {
  type        = list(string)
  description = "list of ssh Ips for ec2 instance"
  default     = ["0.0.0.0/0"]
}

variable "volume_size" {
  type        = number
  description = "Size of the EC2 root volume and EKS cluster nodes"
  default     = 50
}

variable "volume_termination" {
  type        = bool
  description = "Select the volume of the instance and EKS cluster nodes should be delete or not"
  default     = false
}

variable "ec2_instance_type" {
  type        = string
  description = "Provide the type of the EC2 Instance"
  default     = "t3.medium"
}

variable "ec2_subnet_id" {
  type        = string
  description = "ID of the subnet for ec2"
  default     = null
}