provider "aws" {
  region = "us-east-1"
}


module "webserver" {
  source = "../modules/webserver"

  cluster_name  = "prod-app"
  vpc_cidr      = "10.1.0.0/16" # Unique VPC network for Prod!
  instance_type = "t3.small"    # Slightly larger instance for Prod


  public_subnet_cidr = {
    "public-a" = { cidr_block = "10.1.1.0/24", az_index = 0 }
    "public-b" = { cidr_block = "10.1.2.0/24", az_index = 1 }
  }


  private_subnet_cidr = {
    "private-a" = { cidr_block = "10.1.11.0/24", az_index = 0 }
    "private-b" = { cidr_block = "10.1.12.0/24", az_index = 1 }
  }


  # Explicitly declaring for readability
  server_ports = {
    "http" = {
      port        = 80
      description = "Standard HTTP Port"
    }
  }

  # Beefing up the Auto Scaling Group for production traffic
  asg_capacity = {
    min     = 2
    max     = 6
    desired = 2
  }
}

output "prod_alb_dns" {
  value = module.webserver.alb_dns_name
}