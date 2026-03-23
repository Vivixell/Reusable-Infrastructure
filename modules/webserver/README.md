Terraform AWS Highly Available Webserver ModuleThis repository contains a reusable Terraform module designed to deploy a fully configurable, highly available clustered web application architecture on AWS.Instead of hardcoding a single environment, this module acts as a dynamic blueprint. It allows engineering teams to spin up completely isolated, identical environments (Dev, Staging, Prod) simply by passing in different variable inputs, while ensuring strict network isolation and zero-downtime rolling updates out of the box.Architecture OverviewWhen called, this module provisions a robust network and deployment foundation:High Availability: Creates a custom Virtual Private Cloud (VPC) spanning two Availability Zones. An Application Load Balancer (ALB) resides in the public subnets to ingest internet traffic, while an Auto Scaling Group (ASG) manages EC2 instances securely hidden in the private subnets.Zero-Downtime Updates: Configured with lifecycle hooks and instance_refresh strategies so that infrastructure updates (like AMI changes) roll out smoothly across the cluster without dropping active traffic.Zero-Trust Security Groups: The ALB security group allows public traffic on the defined port, but the instance security group explicitly rejects all internet traffic. Instances only accept connections routed directly from the ALB.Usage ExampleTo use this module in your root environment (e.g., dev/main.tf), reference the module source and provide the required network variables:Terraformmodule 


"webserver" {
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
}
InputsNameDescriptionTypeRequiredDefaultcluster_namePrefix used for naming all resources to prevent collisionsstringYes-vpc_cidrThe CIDR block for the VPCstringYes-public_subnet_cidrMap of CIDR blocks and AZ indexes for public subnetsmap(object)Yes-private_subnet_cidrMap of CIDR blocks and AZ indexes for private subnetsmap(object)Yes-instance_typeEC2 instance type for the Auto Scaling GroupstringYes-asg_capacityObject defining min, max, and desired ASG capacityobjectYes-server_portsDictionary mapping application layers to their portsmap(object)No{ "http" = { port = 80 } }OutputsNameDescriptionalb_dns_nameThe public DNS name of the Application Load Balancervpc_idThe ID of the VPC created by the moduleEngineering Decisions & FixesThe Silent Race ConditionWhen initially building the logic for this module, the ALB returned a 502 Bad Gateway. The issue wasn't the code syntax; it was a Terraform race condition. Terraform was spinning up the ASG instances before the NAT Gateway and Internet Gateway were fully provisioned. Because the instances had no internet access upon boot, the user_data script failed to install the web server.The Fix: Introduced explicit dependencies forcing the ASG to wait for network routing to establish before launching instances.Terraformresource "aws_autoscaling_group" "asg" {
  # ... scaling configs ...
  depends_on = [
    aws_nat_gateway.regional_nat,
    aws_route_table_association.private_assoc
  ]
}
Future ImprovementsThis module currently relies on a user_data script to configure the web server on boot. Running apt-get on every scale-out event slows down the ASG response time. A recommended improvement for consumers of this module is to implement an AMI Baking strategy (using tools like HashiCorp Packer) to pass in "Golden AMIs" that boot instantly, reducing scale-out time from minutes to seconds.