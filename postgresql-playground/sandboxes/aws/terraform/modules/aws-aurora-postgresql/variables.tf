variable "cluster_name" {
  type        = string
  description = "Name of the Aurora cluster"
  default     = "postgresql-cluster"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the Aurora cluster will be launched"
}

variable "allowed_availability_zones" {
  type        = list(string)
  description = "List of allowed availability zones for the Aurora cluster"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "subnets_ids" {
  type        = list(string)
  description = "List of subnet IDs where the Aurora cluster will be launched"
}

variable "engine_version" {
  type        = string
  description = "Version of Aurora PostgreSQL. Available options: 10.21, 11.9, 11.13, ..."
  default     = "15.2"

  validation {
    condition     = can(regex("^(10\\.21|11\\.(9|13|14|15|16|17|18|19)|12\\.(8|9|10|11|12|13|14)|13\\.(4|5|6|7|8|9|10)|14\\.(3|4|5|6|7))|15\\.2$", var.engine_version))
    error_message = "Invalid engine version. Please choose from the available options."
  }
}

variable "instance_type" {
  type        = string
  description = "Instance type for the Aurora instances"
  default     = "db.t3.medium"

  validation {
    condition     = can(regex("^db.(t3.medium)$", var.instance_type))
    error_message = "Invalid instance type. Only db.t3.medium is allowed."
  }
}

variable "cluster_port" {
  type        = number
  description = "Port number of the Aurora cluster"
  default     = 5432
}

variable "master_username" {
  type        = string
  description = "Username for the master user"
  default     = "postgres"
}

variable "num_instances" {
  type        = number
  description = "Number of Aurora instances"
  default     = 2
}

variable "storage_encrypted" {
  description = "Whether to enable storage encryption for the Aurora cluster"
  type        = bool
  default     = true
}
