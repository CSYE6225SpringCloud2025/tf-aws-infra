output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.gw.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private_rt.id
}

# output "ec2_instance_id" {
#   description = "The ID of the EC2 instance"
#   value       = aws_instance.web_application.id
# }

output "rds_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.web_app_db.endpoint
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.web_app_bucket.bucket
}

# New outputs for load balancer and auto-scaling
output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.web_app_lb.dns_name
}

output "load_balancer_zone_id" {
  description = "The zone ID of the load balancer"
  value       = aws_lb.web_app_lb.zone_id
}

output "auto_scaling_group_name" {
  description = "The name of the auto scaling group"
  value       = aws_autoscaling_group.web_app_asg.name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.web_app_tg.arn
}

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.web_app_launch_template.id
}

output "kms_key_arns" {
  description = "The ARNs of the KMS keys"
  value = {
    ec2     = aws_kms_key.ec2_key.arn
    rds     = aws_kms_key.rds_key.arn
    s3      = aws_kms_key.s3_key.arn
    secrets = aws_kms_key.secrets_key.arn
  }
}

output "db_secret_arn" {
  description = "The ARN of the database secret"
  value       = aws_secretsmanager_secret.db_password.arn
}