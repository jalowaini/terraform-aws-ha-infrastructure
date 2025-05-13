variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "project_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  default = {
    "us-east-1a" = 10
    "us-east-1b" = 20
  }
}

variable "private_subnets" {
  default = {
    "us-east-1a" = 100
    "us-east-1b" = 200
  }
}
variable "allowed_ports" {
  type    = list(any)
  default = ["22", "80", "443"]
}

