module "EKS-SG" {
	source	=	"./EKS-Cluster-SG"
	ProjectName	=	var.ProjectName
	Environment	=	var.Environment
	CidrIp	=	var.CidrIp
	VpcId	=	var.VpcId
}

module "EKS-Cluster-Nodegroup-SG" {
	source	=	"./EKS-NodeGroup-SG"
	ProjectName	=	var.ProjectName
	Environment	=	var.Environment
	VpcId	=	var.VpcId
}

module "EKS-Cluster-IAM-Role"{
	source	=	"./EKS-Cluster-IAM-Role"
	ProjectName	=	var.ProjectName
	Environment	=	var.Environment
}

module "EKS-Cluster-NodeGroup-Role"	{
	source	=	"./EKS-Cluster-Nodegroup-IAM-Role"
	ProjectName	=	var.ProjectName
	Environment	=	var.Environment
	NodeGroupName	=	var.NodeGroupName
}

module "EKS-Cluster" {
	source	=	"./EKS-Cluster"
	ProjectName	=	var.ProjectName
	Environment	=	var.Environment
	PrivateSubnetID	=	var.PrivateSubnetID
	ClusterSecurityGroup	=	module.EKS-SG.EKS-Cluster-SG-Output.id
	EKSVersion	=	var.EKSVersion
	KubeAPIEndpoint	=	var.KubeAPIEndpoint
	ControlPlaneLogs	=	var.ControlPlaneLogs
	EKSClusterRoleARN	=	module.EKS-Cluster-IAM-Role.EKS-Cluster-IAM-Role-ARN.arn
}

module "EKS-Cluster-NodeGroup" {
	source	=	"./EKS-NodeGroup"
	Region	= var.Region
	ProjectName	=	var.ProjectName
	Environment	=	var.Environment
	ClusterName	=	module.EKS-Cluster.EKSClusterName.name
	NodeGroupName	=	var.NodeGroupName
	NodeInstanceRole	=	module.EKS-Cluster-NodeGroup-Role.EKS-Cluster-Nodegroup-IAM-Role-ARN.arn
	NodeImageIdSSMParam	=	var.NodeImageIdSSMParam
	NodeInstanceType	=	var.NodeInstanceType
	PrivateSubnetID	=	var.PrivateSubnetID
	KeyName	=	var.KeyName
	ManagedNodeDesiredInstanceCount	=	var.ManagedNodeDesiredInstanceCount
	ManagedNodeMaxInstanceCount	=	var.ManagedNodeMaxInstanceCount
	ManagedNodeMinInstanceCount	=	var.ManagedNodeMinInstanceCount
	WorkerNodesSecurityGroup	=	module.EKS-Cluster-Nodegroup-SG.EKS-Cluster-NodeGroup-SG-ID.id
	AMIArchitectureForNodeGroup	=	var.AMIArchitectureForNodeGroup
	ClusterType	=	var.ClusterType
	DiskSize	=	var.DiskSize
}