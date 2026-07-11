provider "aws" {
    region = "us-west-2"
}

resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-lt-"
  image_id      = var.ami_id
  instance_type = "t2.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "Hello from Auto Scaling Group" > /var/www/html/index.html
EOF
)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ASG-instance"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = data.aws_subnets.public.ids
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
