output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.project_alb.dns_name
}

output "web_instance_private_ip" {
  description = "Private IP address of web instance"
  value       = aws_instance.web.private_ip
}

output "app_instance_private_ip" {
  description = "Private IP address of app instance"
  value       = aws_instance.app.private_ip
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.rds_instance.endpoint
  sensitive   = true
}