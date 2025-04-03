variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "custom_ami_id" {
  description = "ID of the custom AMI"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "application_port" {
  description = "Port on which the application runs"
  type        = number
}

variable "db_port" {
  description = "Port for the database"
  type        = number
  default     = 3306
}

variable "db_engine" {
  description = "Database engine (e.g., mysql, postgres)"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "5.7"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t2.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the database (in GB)"
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "Database storage type"
  type        = string
  default     = "gp2"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "csye6225"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "csye6225"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_instance_identifier" {
  description = "Database instance identifier"
  type        = string
  default     = "csye6225"
}

variable "db_parameter_group_family" {
  description = "Database parameter group family"
  type        = string
  default     = "mysql5.7"
}

# New variables for auto-scaling and load balancer
variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

# variable "route53_zone_id" {
#   description = "Route53 hosted zone ID"
#   type        = string
# }

# variable "domain_name" {
#   description = "Domain name for the application"
#   type        = string
# }

variable "environment" {
  description = "Environment (dev or demo)"
  type        =  string
}

variable "zone_id" {
  description = "Hosted zone ID"
  type        =  string
}