variable "region_name" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "profile_name" {
  description = "AWS CLI profile for authentication"
  type        = string
}

variable "vpcs" {
  description = "List of VPCs with their respective CIDR blocks"
  type = list(object({
    name       = string
    cidr_block = string
  }))
  default = [
    { name = "vpc1", cidr_block = "10.0.0.0/16" },
    { name = "vpc2", cidr_block = "10.1.0.0/16" }
  ]
}

variable "num_public_subnets" {
  description = "Number of public subnets to create per VPC"
  type        = number
  default     = 3
}

variable "num_private_subnets" {
  description = "Number of private subnets to create per VPC"
  type        = number
  default     = 3
}

variable "availability_zones" {
  description = "List of availability zones for subnet distribution"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
