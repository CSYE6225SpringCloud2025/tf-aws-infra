# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_assoc" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_assoc" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Current AWS account data - Moved up to be used in KMS key policy
data "aws_caller_identity" "current" {}

# # General KMS key policy document for EC2, RDS, and S3 keys
# data "aws_iam_policy_document" "kms_key_policy" {
#   # Allow root account full access (including policy updates)
#   statement {
#     sid    = "EnableRootPermissions"
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#     actions   = ["kms:*"]
#     resources = ["*"]
#   }

#   # Allow key administrators to manage the key
#   statement {
#     sid    = "AllowKeyAdministration"
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/DemoVarnika"]
#     }
#     actions = [
#       "kms:Create*",
#       "kms:Describe*",
#       "kms:Enable*",
#       "kms:List*",
#       "kms:Put*",
#       "kms:Update*",
#       "kms:Revoke*",
#       "kms:Disable*",
#       "kms:Get*",
#       "kms:Delete*",
#       "kms:ScheduleKeyDeletion",
#       "kms:CancelKeyDeletion",
#       "kms:TagResource",
#       "kms:UntagResource"
#     ]
#     resources = ["*"]
#   }

#   # Allow AWS services to use the key
#   statement {
#     sid    = "AllowServiceUse"
#     effect = "Allow"
#     principals {
#       type = "Service"
#       identifiers = [
#         "logs.${var.aws_region}.amazonaws.com",
#         "rds.amazonaws.com",
#         "s3.amazonaws.com"
#       ]
#     }
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey"
#     ]
#     resources = ["*"]
#   }
# }

# # Specific policy document for Secrets Manager KMS key
# data "aws_iam_policy_document" "secrets_key_policy" {
#   # Allow root account full access
#   statement {
#     sid    = "EnableRootPermissions"
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#     actions   = ["kms:*"]
#     resources = ["*"]
#   }

#   # Allow key administrators to manage the key
#   statement {
#     sid    = "AllowKeyAdministration"
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/DemoVarnika"]
#     }
#     actions = [
#       "kms:Create*",
#       "kms:Describe*",
#       "kms:Enable*",
#       "kms:List*",
#       "kms:Put*",
#       "kms:Update*",
#       "kms:Revoke*",
#       "kms:Disable*",
#       "kms:Get*",
#       "kms:Delete*",
#       "kms:ScheduleKeyDeletion",
#       "kms:CancelKeyDeletion",
#       "kms:TagResource",
#       "kms:UntagResource"
#     ]
#     resources = ["*"]
#   }

#   # Explicitly allow Secrets Manager to use the key
#   statement {
#     sid    = "AllowSecretsManagerService"
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["secretsmanager.amazonaws.com"]
#     }
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey",
#       "kms:CreateGrant",
#       "kms:ListGrants",
#       "kms:RevokeGrant"
#     ]
#     resources = ["*"]
#   }

#   # Allow the current account to use the key (important for cross-service permissions)
#   statement {
#     sid    = "AllowAccountUsage"
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey",
#       "kms:CreateGrant"
#     ]
#     resources = ["*"]
#   }
# }

# data "aws_iam_policy_document" "kms_key_policy" {
#   # Allow root account full access (including policy updates)
#   statement {
#     sid    = "EnableRootPermissions"
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#     actions   = ["kms:*"]
#     resources = ["*"]
#   }

#   # Allow key administrators to manage the key
#   statement {
#     sid    = "AllowKeyAdministration"
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/DemoVarnika"]
#     }
#     actions = [
#       "kms:Create*",
#       "kms:Describe*",
#       "kms:Enable*",
#       "kms:List*",
#       "kms:Put*",
#       "kms:Update*",
#       "kms:Revoke*",
#       "kms:Disable*",
#       "kms:Get*",
#       "kms:Delete*",
#       "kms:ScheduleKeyDeletion",
#       "kms:CancelKeyDeletion",
#       "kms:TagResource",
#       "kms:UntagResource"
#     ]
#     resources = ["*"]
#   }

#   # Allow EC2 role to use the key
#   statement {
#     sid    = "AllowEC2RoleToUseKey"
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = [aws_iam_role.ec2_role.arn]
#     }
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey"
#     ]
#     resources = ["*"]
#   }

#   # Allow AWS services to use the key
#   statement {
#     sid    = "AllowServiceUse"
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = [
#         "logs.${var.aws_region}.amazonaws.com",
#         "secretsmanager.amazonaws.com",
#         "rds.amazonaws.com",
#         "s3.amazonaws.com"
#       ]
#     }
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey"
#     ]
#     resources = ["*"]
#   }
# }

resource "random_id" "secret_suffix" {
  byte_length = 4
}

# Secrets Manager for DB Password
resource "aws_secretsmanager_secret" "db_password" {
  name       = "${var.project_name}-db-password-${random_id.secret_suffix.hex}"
  kms_key_id = aws_kms_key.secrets_key.key_id

  # Add explicit dependency on the KMS key
  depends_on = [aws_kms_key.secrets_key]

  tags = {
    Name = "${var.project_name}-db-password"
  }
}


resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({ password = random_password.db_password.result })
}

# Generate random password for DB
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%^&*"
}

# Load Balancer Security Group
resource "aws_security_group" "load_balancer_security_group" {
  name        = "${var.project_name}-lb-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-lb-sg"
  }
}

# # Application Security Group
# resource "aws_security_group" "application_security_group" {
#   name        = "${var.project_name}-app-sg"
#   description = "Allow SSH, HTTP, HTTPS, and application port traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = var.application_port
#     to_port     = var.application_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# Updated Application Security Group (restrict access)
# Have updated the Application Security group, attatched load balancer security group, to make 
# sure all the traffic passses through the load balancer
# i.e allowing traffic on your application port through load balancer
resource "aws_security_group" "application_security_group" {
  name        = "${var.project_name}-app-sg"
  description = "Allow SSH and application port traffic from load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  ingress {
    from_port       = var.application_port
    to_port         = var.application_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# Database Security Group
resource "aws_security_group" "database_security_group" {
  name        = "${var.project_name}-db-sg"
  description = "Allow traffic from application security group to database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.application_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

# IAM Policy for S3 Access
resource "aws_iam_role_policy" "s3_policy" {
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = [aws_s3_bucket.web_app_bucket.arn, "${aws_s3_bucket.web_app_bucket.arn}/*"]
      }
    ]
  })
}


# IAM Policy for Secrets Manager Access
#added KMS to secrets policy
resource "aws_iam_role_policy" "secrets_policy" {
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.db_password.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch IAM Policy
resource "aws_iam_role_policy" "cloudwatch_policy" {
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# S3 Bucket
resource "aws_s3_bucket" "web_app_bucket" {
  bucket = "${var.project_name}-${uuid()}"

  force_destroy = true

  tags = {
    Name = "${var.project_name}-s3-bucket"
  }
}

# resource "aws_s3_bucket_server_side_encryption_configuration" "web_app_bucket_encryption" {
#   bucket = aws_s3_bucket.web_app_bucket.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

resource "aws_s3_bucket_server_side_encryption_configuration" "web_app_bucket_encryption" {
  bucket = aws_s3_bucket.web_app_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "web_app_bucket_lifecycle" {
  bucket = aws_s3_bucket.web_app_bucket.bucket

  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "web_app_db_parameter_group" {
  name   = "${var.project_name}-db-parameter-group"
  family = var.db_parameter_group_family

  tags = {
    Name = "${var.project_name}-db-parameter-group"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "web_app_db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "web_app_db" {
  identifier             = var.db_instance_identifier
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = var.db_storage_type
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  parameter_group_name   = aws_db_parameter_group.web_app_db_parameter_group.name
  db_subnet_group_name   = aws_db_subnet_group.web_app_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_key.arn

  tags = {
    Name = "${var.project_name}-db-instance"
  }
}

# Launch Template (replaces EC2 instance)
resource "aws_launch_template" "web_app_launch_template" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = var.custom_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application_security_group.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_key.arn
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              REGION="${var.aws_region}"
              SECRET_NAME="${aws_secretsmanager_secret.db_password.name}"
              echo "DB_PASSWORD=$(aws secretsmanager get-secret-value --region $REGION --secret-id $SECRET_NAME --query SecretString --output text | jq -r '.password')" > /opt/webapp/.env

              echo "DB_HOST=${aws_db_instance.web_app_db.address}" >> /opt/webapp/.env
              echo "DB_USERNAME=${var.db_username}" >> /opt/webapp/.env
              echo "DB_NAME=${var.db_name}" >> /opt/webapp/.env
              echo "DB_DIALECT=mysql" >> /opt/webapp/.env
              echo "S3_BUCKET_NAME=${aws_s3_bucket.web_app_bucket.bucket}" >> /opt/webapp/.env

              # Configure CloudWatch Agent
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config \
                -m ec2 \
                -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
                -s

              sudo chown -R csye6225:csye6225 /opt/webapp
              sudo chmod 600 /opt/webapp/.env
              sudo systemctl restart webapp.service
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-web-app-instance"
    }
  }
}

# Application Load Balancer
resource "aws_lb" "web_app_lb" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-lb"
  }
}

resource "aws_lb_target_group" "web_app_tg" {
  name     = "${var.project_name}-tg"
  port     = var.application_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# ACM Certificate for DEV environment
# resource "aws_acm_certificate" "dev_cert" {
#   count = var.environment == "dev" ? 1 : 0

#   domain_name       = "${var.environment}.varnikamujumdar.me"
#   validation_method = "DNS"

#   tags = {
#     Name = "${var.project_name}-dev-cert"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# Imported certificate for DEMO environment
# resource "aws_acm_certificate" "demo_cert" {
#   count = var.environment == "demo" ? 1 : 0

#   private_key       = var.certificate_private_key
#   certificate_body  = var.certificate_body
#   certificate_chain = var.certificate_chain

#   tags = {
#     Name = "${var.project_name}-demo-cert"
#   }
# }

data "aws_acm_certificate" "cert" {
  domain      = "${var.environment}.varnikamujumdar.me"
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "web_app_listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_tg.arn
  }
}

# HTTPS Listener
# resource "aws_lb_listener" "web_app_https" {
#   load_balancer_arn = aws_lb.web_app_lb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.environment == "dev" ? aws_acm_certificate.dev_cert[0].arn : aws_acm_certificate.demo_cert[0].arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.web_app_tg.arn
#   }
# }

# HTTP Listener (redirect not required per assignment)
# resource "aws_lb_listener" "web_app_http" {
#   load_balancer_arn = aws_lb.web_app_lb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "HTTP access not supported"
#       status_code  = "403"
#     }
#   }
# }

# Auto Scaling Group
resource "aws_autoscaling_group" "web_app_asg" {
  name_prefix               = "${var.project_name}-asg-"
  vpc_zone_identifier       = aws_subnet.public_subnets[*].id
  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 5
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true

  launch_template {
    id      = aws_launch_template.web_app_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_app_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

# CloudWatch Alarms for Scaling
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 12
  alarm_description   = "Scale up when CPU > 12% for 1 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.project_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "Scale down when CPU < 3% for 2 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }
}

# Route53 Record for Load Balancer
resource "aws_route53_record" "web_app_record" {
  zone_id = var.zone_id
  name    = "${var.environment}.varnikamujumdar.me"
  type    = "A"

  alias {
    name                   = aws_lb.web_app_lb.dns_name
    zone_id                = aws_lb.web_app_lb.zone_id
    evaluate_target_health = true
  }
}

# KMS Keys
resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 encryption"
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 7

  tags = {
    Name = "${var.project_name}-ec2-key"
  }
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid    = "Allow Autoscaling Service",
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Sid       = "Allow EC2 Role Access"
        Effect    = "Allow"
        Principal = { "AWS" : aws_iam_role.ec2_role.arn }
        Action = [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Auto Scaling and EC2 Services"
        Effect = "Allow"
        Principal = {
          "Service" : [
            "autoscaling.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        }
        Action = [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption"
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 7

  tags = {
    Name = "${var.project_name}-rds-key"
  }
}


resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 encryption"
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 7

  tags = {
    Name = "${var.project_name}-s3-key"
  }
}

resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for Secrets Manager"
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 7

  tags = {
    Name = "${var.project_name}-secrets-key"
  }
}
