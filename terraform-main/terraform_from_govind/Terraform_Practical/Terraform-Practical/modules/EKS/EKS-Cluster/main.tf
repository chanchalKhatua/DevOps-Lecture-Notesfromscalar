data "aws_caller_identity" "current" {}

resource "aws_kms_key" "KMSKey" {
  description = "Encrypt sensitive data for EKS Cluster."
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "Allow administration of the key",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
        },
        {
        "Sid": "Allow use of the key",
        "Effect": "Allow",
        "Principal": {
            "AWS": "*"
        },
        "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
        ],
        "Resource": "*"
        }
    ]
    })
  tags = {
    "Name" = "${var.ProjectName}-${var.Environment}-EKSClusterKMS"
    "Environment" = var.Environment
  }
}

resource "aws_kms_alias" "name" {
  name = "alias/${var.ProjectName}-${var.Environment}-KMS"
  target_key_id = aws_kms_key.KMSKey.arn
}

resource "aws_eks_cluster" "EKSClusterWithControlPlaneLogs" {
  count = var.ControlPlaneLogs?1:0
  name = "${var.ProjectName}-${var.Environment}-EKSCluster"
  version = var.EKSVersion
  role_arn = var.EKSClusterRoleARN
  encryption_config {
    provider {
      key_arn = aws_kms_key.KMSKey.arn
    }
    resources = [ "secrets" ]
  }
  vpc_config {
    security_group_ids = [ var.ClusterSecurityGroup ]
    subnet_ids = var.PrivateSubnetID
    endpoint_private_access = var.KubeAPIEndpoint?false:true
    endpoint_public_access = var.KubeAPIEndpoint?true:false
  }
  enabled_cluster_log_types = [ "api", "audit", "authenticator", "controllerManager", "scheduler" ]
  tags = {
    "Name"="${var.ProjectName}-${var.Environment}-EKSCluster"
    "Environment"="${var.Environment}"
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_cluster" "EKSClusterWithOutControlPlaneLogs" {
  count = var.ControlPlaneLogs?0:1
  name = "${var.ProjectName}-${var.Environment}-EKSCluster"
  version = var.EKSVersion
  role_arn = var.EKSClusterRoleARN
  encryption_config {
    provider {
      key_arn = aws_kms_key.KMSKey.arn
    }
    resources = [ "secrets" ]
  }
  vpc_config {
    security_group_ids = [ var.ClusterSecurityGroup ]
    subnet_ids = var.PrivateSubnetID
    endpoint_private_access = var.KubeAPIEndpoint?false:true
    endpoint_public_access = var.KubeAPIEndpoint?true:false
  }
  tags = {
    "Name"="${var.ProjectName}-${var.Environment}-EKSCluster"
    "Environment"="${var.Environment}"
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_iam_openid_connect_provider" "PublicClusterOIDCProvider" {
  url = length(aws_eks_cluster.EKSClusterWithControlPlaneLogs)>0 ? aws_eks_cluster.EKSClusterWithControlPlaneLogs[0].identity[0].oidc[0].issuer:aws_eks_cluster.EKSClusterWithOutControlPlaneLogs[0].identity[0].oidc[0].issuer
  client_id_list = [ "sts.amazonaws.com" ]
  thumbprint_list = [ "9e99a48a9960b14926bb7f3b02e22da2b0ab7280" ]
}

