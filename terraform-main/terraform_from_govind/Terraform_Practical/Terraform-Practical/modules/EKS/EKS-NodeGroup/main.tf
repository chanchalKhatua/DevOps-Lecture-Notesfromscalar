locals {
  partition_map = {
    "aws" = {
      "EC2ServicePrincipal" = "ec2.amazonaws.com"
    }
    "aws-us-gov" = {
      "EC2ServicePrincipal" = "ec2.amazonaws.com"
    }
    "aws-cn" = {
      "EC2ServicePrincipal" = "ec2.amazonaws.com.cn"
    }
    "aws-iso" = {
      "EC2ServicePrincipal" = "ec2.c2s.ic.gov"
    }
    "aws-iso-b" = {
      "EC2ServicePrincipal" = "ec2.sc2s.sgov.gov"
    }
  }
}

data "aws_partition" "current" {}

data "aws_ssm_parameter" "ImageID" {
  name = var.NodeImageIdSSMParam
}

resource "aws_eks_node_group" "EksNodeGroup" {
  tags = {
    Name = "${var.ProjectName}-${var.Environment}-${var.NodeGroupName}"
    IaaC="Terraform"
    Environment="${var.Environment}"
  }
  cluster_name = var.ClusterName
  node_role_arn = var.NodeInstanceRole
  subnet_ids = var.PrivateSubnetID
  scaling_config {
    desired_size = var.ManagedNodeDesiredInstanceCount
    min_size = var.ManagedNodeMinInstanceCount
    max_size = var.ManagedNodeMaxInstanceCount
  }
  ami_type = var.AMIArchitectureForNodeGroup
  capacity_type = var.ClusterType
  launch_template {
    id = aws_launch_template.EKSLaunchTemplate.id
    version = aws_launch_template.EKSLaunchTemplate.latest_version
  }
  node_group_name = "${var.ProjectName}-${var.Environment}-${var.NodeGroupName}"
}

resource "aws_launch_template" "EKSLaunchTemplate" {
  name = "${var.ProjectName}-${var.Environment}-LT"
  network_interfaces {
    security_groups = [ var.WorkerNodesSecurityGroup ]
  }
  key_name = var.KeyName
  instance_type = var.NodeInstanceType
  image_id = data.aws_ssm_parameter.ImageID.value
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = var.DiskSize
      volume_type = "gp3"
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
        Name="${var.ProjectName}-${var.Environment}-EKS-NODE",
        Environment = var.Environment
        IaaC="Terraform"
    }
  }
  user_data = base64encode(<<-EOF
            #!/bin/bash
            set -o xtrace
            iid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
            export AWS_DEFAULT_REGION=${var.Region}
            ilc=`aws ec2 describe-instances --instance-ids  $iid  --query 'Reservations[0].Instances[0].InstanceLifecycle' --output text`
            if [ "$ilc" == "spot" ]; then
              /etc/eks/bootstrap.sh ${var.ClusterName} ${var.BootstrapArgumentsForSpotFleet}
            else
              /etc/eks/bootstrap.sh ${var.ClusterName} ${var.BootstrapArgumentsForOnDemand} --container-runtime containerd
            fi
            EOF
            )
}