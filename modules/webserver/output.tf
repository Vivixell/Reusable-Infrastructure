output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "vpc_id" {
  description = "The ID of the VPC created by the module"
  value       = aws_vpc.this.id
}