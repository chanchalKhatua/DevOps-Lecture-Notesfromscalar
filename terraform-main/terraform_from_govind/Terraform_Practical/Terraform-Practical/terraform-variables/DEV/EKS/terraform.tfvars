######################
/* Common Variables */
######################

Region = "ap-south-1"
ProjectName = "Pramod-Test"
Environment = "DEV"
VpcId = "vpc-023c79a9f1171c708"
CidrIp  = "172.31.0.0/16"
PrivateSubnetID = [
  "subnet-06970f2a9c80a062e",
  "subnet-0b39ca0ea9fd211f9",
]

######################
/* EKS Variables */
######################

EKSVersion = "1.28"
ControlPlaneLogs = "false"
KubeAPIEndpoint = "false"

########################
/* EKS Node Variables */
########################

NodeGroupName = "NG"
NodeInstanceType = "t3a.medium"
KeyName = "Pramod-KP"
ManagedNodeDesiredInstanceCount = "1"
ManagedNodeMaxInstanceCount = "2"
ManagedNodeMinInstanceCount = "1"
NodeImageIdSSMParam = "/aws/service/eks/optimized-ami/1.28/amazon-linux-2/recommended/image_id"
