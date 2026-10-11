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

resource "aws_iam_role" "EKS-Cluster-NodeInstanceRole" {
  name               = "${var.ProjectName}-${var.Environment}-${var.NodeGroupName}-ROLE"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = [
            local.partition_map[data.aws_partition.current.partition]["EC2ServicePrincipal"]
          ]
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = "${var.ProjectName}-${var.Environment}-EKS-Node-Cluster-Autoscaling-ALB-Policy"
    policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
          "Action": [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeTags",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "ec2:DescribeLaunchTemplateVersions"
            ],
          "Effect": "Allow",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "acm:DescribeCertificate",
            "acm:ListCertificates",
            "acm:GetCertificate"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CreateSecurityGroup",
            "ec2:CreateTags",
            "ec2:DeleteTags",
            "ec2:DeleteSecurityGroup",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeTags",
            "ec2:DescribeVpcs",
            "ec2:ModifyInstanceAttribute",
            "ec2:ModifyNetworkInterfaceAttribute",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:DescribeAvailabilityZones"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "elasticloadbalancing:AddListenerCertificates",
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:CreateRule",
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:DeleteRule",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:DescribeListenerCertificates",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeLoadBalancerAttributes",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:DescribeSSLPolicies",
            "elasticloadbalancing:DescribeTags",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetGroupAttributes",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "elasticloadbalancing:ModifyRule",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:RemoveListenerCertificates",
            "elasticloadbalancing:RemoveTags",
            "elasticloadbalancing:SetIpAddressType",
            "elasticloadbalancing:SetSecurityGroups",
            "elasticloadbalancing:SetSubnets",
            "elasticloadbalancing:SetWebACL"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "iam:CreateServiceLinkedRole",
            "iam:GetServerCertificate",
            "iam:ListServerCertificates"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "cognito-idp:DescribeUserPoolClient"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "waf-regional:GetWebACLForResource",
            "waf-regional:GetWebACL",
            "waf-regional:AssociateWebACL",
            "waf-regional:DisassociateWebACL",
            "wafv2:GetWebACLForResource"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "tag:GetResources",
            "tag:TagResources"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "waf:GetWebACL"
          ],
          "Resource": "*"
        }
    ]
  })
  }
  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  tags = {
    Name = "${var.ProjectName}-${var.Environment}-NodeGroupRole"
    "Environment"="${var.Environment}"
  }
}