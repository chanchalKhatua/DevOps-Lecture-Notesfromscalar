output "EKSClusterName" {
  value = length(aws_eks_cluster.EKSClusterWithControlPlaneLogs)>0?aws_eks_cluster.EKSClusterWithControlPlaneLogs[0].name:aws_eks_cluster.EKSClusterWithOutControlPlaneLogs[0]
}

output "EKSClusterARN" {
  value = length(aws_eks_cluster.EKSClusterWithControlPlaneLogs)>0?aws_eks_cluster.EKSClusterWithControlPlaneLogs[0].arn:aws_eks_cluster.EKSClusterWithOutControlPlaneLogs[0]
}

output "EKSClusterEndpoint" {
  value = length(aws_eks_cluster.EKSClusterWithControlPlaneLogs)>0?aws_eks_cluster.EKSClusterWithControlPlaneLogs[0].endpoint:aws_eks_cluster.EKSClusterWithOutControlPlaneLogs[0]
}