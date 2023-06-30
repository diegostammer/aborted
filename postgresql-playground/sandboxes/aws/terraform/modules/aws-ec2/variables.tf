variable "vpc_id" {
  description = "ID of the VPC where the EC2 instance will be launched"
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance will be launched"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair for accessing the EC2 instance"
  default     = "Default Key Pair"
}

variable "ssh_key_file" {
  description = "SSH key pair data for accessing the EC2 instance"
  default     = "~/.ssh/id_rsa.pub"
}

variable "instance_type" {
  description = "Instance type of this EC2 instance."
  default     = "t2.micro"
}

variable "instance_name" {
  type        = string
  description = "Name of the EC2 instance"
  default     = "ec2-instance"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for the EC2 instance"
}
