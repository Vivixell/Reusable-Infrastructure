variable "cluster_name" {
  description = "The name to use for all cluster resources (e.g., dev-app, prod-app)"
  type        = string
}


variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}



variable "public_subnet_cidr" {
  description = "The CIDR blocks and AZ indexes for public subnets"
  type = map(object({
    cidr_block = string
    az_index   = number
  }))
}


variable "private_subnet_cidr" {
  description = "The CIDR blocks and AZ indexes for private subnets"
  type = map(object({
    cidr_block = string
    az_index   = number
  }))
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}


variable "asg_capacity" {
  description = "Capacity settings for the Auto Scaling Group"
  type = object({
    min     = number
    max     = number
    desired = number
  })
}


variable "server_ports" {
  description = "A dictionary mapping application layers to their ports"
  type = map(object({
    port        = number
    description = string
  }))
  default = {
    "http" = {
      port        = 80
      description = "Standard web traffic"
    }
  }
}