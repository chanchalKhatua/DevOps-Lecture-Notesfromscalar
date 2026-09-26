# Demo 6: Multi-Environment Workspaces
# Single configuration that adapts based on workspace

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = terraform.workspace
      ManagedBy   = "Terraform"
      Project     = "workspace-demo"
    }
  }
}

# Environment-specific configuration
locals {
  environment_config = {
    development = {
      instance_type      = "t2.micro"
      instance_count     = 1
      enable_monitoring  = false
      db_instance_class  = "db.t3.micro"
      vpc_cidr          = "10.0.0.0/16"
      availability_zones = 1
      backup_retention   = 1
      multi_az          = false
    }
    staging = {
      instance_type      = "t2.small"
      instance_count     = 2
      enable_monitoring  = true
      db_instance_class  = "db.t3.small"
      vpc_cidr          = "10.1.0.0/16"
      availability_zones = 2
      backup_retention   = 7
      multi_az          = false
    }
    production = {
      instance_type      = "t3.medium"
      instance_count     = 3
      enable_monitoring  = true
      db_instance_class  = "db.t3.medium"
      vpc_cidr          = "10.2.0.0/16"
      availability_zones = 3
      backup_retention   = 30
      multi_az          = true
    }
  }
  
  # Get current environment config
  config = local.environment_config[terraform.workspace]
  
  # Validate workspace
  valid_workspaces = keys(local.environment_config)
  is_valid_workspace = contains(local.valid_workspaces, terraform.workspace)
}

# Workspace validation
resource "null_resource" "workspace_validation" {
  count = local.is_valid_workspace ? 0 : 1
  
  provisioner "local-exec" {
    command = "echo 'ERROR: Invalid workspace \"${terraform.workspace}\". Valid workspaces: ${join(\", \", local.valid_workspaces)}' && exit 1"
  }
}

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = local.config.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${terraform.workspace}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${terraform.workspace}-igw"
  }
}

# Subnets (number based on environment)
resource "aws_subnet" "public" {
  count = local.config.availability_zones
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.config.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${terraform.workspace}-public-subnet-${count.index + 1}"
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  count = local.config.availability_zones
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.config.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${terraform.workspace}-private-subnet-${count.index + 1}"
    Type = "private"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${terraform.workspace}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "web" {
  name_prefix = "${terraform.workspace}-web-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.config.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${terraform.workspace}-web-sg"
  }
}

# Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "${terraform.workspace}-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = local.config.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    environment = terraform.workspace
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${terraform.workspace}-web-server"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "${terraform.workspace}-web-asg"
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  
  min_size         = local.config.instance_count
  max_size         = local.config.instance_count * 2
  desired_capacity = local.config.instance_count

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-web-asg"
    propagate_at_launch = false
  }
}

# Application Load Balancer
resource "aws_lb" "web" {
  name               = "${terraform.workspace}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${terraform.workspace}-web-alb"
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "${terraform.workspace}-alb-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "${terraform.workspace}-alb-sg"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${terraform.workspace}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "${terraform.workspace}-web-tg"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${terraform.workspace}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${terraform.workspace}-db-subnet-group"
  }
}

# RDS Instance (environment-specific configuration)
resource "aws_db_instance" "main" {
  identifier = "${terraform.workspace}-database"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = local.config.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = "appdb"
  username = "admin"
  password = random_password.db_password.result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = local.config.backup_retention
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  multi_az               = local.config.multi_az
  publicly_accessible    = false
  
  skip_final_snapshot = true
  deletion_protection = terraform.workspace == "production" ? true : false

  tags = {
    Name = "${terraform.workspace}-database"
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_security_group" "rds" {
  name_prefix = "${terraform.workspace}-rds-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  tags = {
    Name = "${terraform.workspace}-rds-sg"
  }
}

# CloudWatch Dashboard (only for staging and production)
resource "aws_cloudwatch_dashboard" "main" {
  count = local.config.enable_monitoring ? 1 : 0

  dashboard_name = "${terraform.workspace}-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.web.arn_suffix],
            [".", "TargetResponseTime", ".", "."],
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB Metrics"
          period  = 300
        }
      }
    ]
  })
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}