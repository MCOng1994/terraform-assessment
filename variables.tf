variable "project" {
  default     = "maybank"
  description = "Project name"
}

variable "env" {
  default     = "test"
  description = "Deployment environment"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "public_subnets" {
  type = list(string)
  default = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "private_subnets" {
  type = list(string)
  default = ["192.168.101.0/24", "192.168.102.0/24"]
}

variable "ssm_host_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_instance_type" {
  type    = string
  default = "t3.small"
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 2
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_engine_version" {
  type    = string
  default = "10.5"
}

variable "alb_health_check_path" {
  type    = string
  default = "/"
}

variable "tags" {
  type = map(string)
  default = {
    Project = "iactest"
    Owner   = "student"
  }
}
