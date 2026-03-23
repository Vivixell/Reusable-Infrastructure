provider "aws" {
  region = "us-east-1"
}


module "webserver" {
  source = "../modules/webserver"


  cluster_name  = "dev-app"
  vpc_cidr      = "10.0.0.0/16"
  instance_type = "t3.micro"

  public_subnet_cidr = {
    "public-a" = { cidr_block = "10.0.1.0/24", az_index = 0 }
    "public-b" = { cidr_block = "10.0.2.0/24", az_index = 1 }
  }


  private_subnet_cidr = {
    "private-a" = { cidr_block = "10.0.11.0/24", az_index = 0 }
    "private-b" = { cidr_block = "10.0.12.0/24", az_index = 1 }
  }


  asg_capacity = {
    min     = 2
    max     = 4
    desired = 2
  }

  server_ports = {
    "http" = {
      port = 80
      description = "HTTP traffic"
    }
  }


}

# We pass the module's output up to the root so you can see it in your terminal
output "dev_alb_dns" {
  value = module.webserver.alb_dns_name
}

