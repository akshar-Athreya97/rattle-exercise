output "cluster_iam_role_name" {
    value = aws_iam_role.eks-iamcluster-role.name
}

output "cluster_iam_role_arn" {
    value = aws_iam_role.eks-iamcluster-role.arn
}

output "worker_iam_role_name" {
    value = aws_iam_role.eks-workernode-role.name
}

output "worker_iam_role_arn" {
    value = aws_iam_role.eks-workernode-role.arn
}

output "cluster_name" {
    description = "EKS Cluster Name"
    value = aws_eks_cluster.eks-cluster.name
}

output "cluster_id" {
    description = "EKS Cluster ID"
    value = aws_eks_cluster.eks-cluster.id
}
output "sec_group" {
    description = "EKS Primary SG"
    value = aws_security_group.cluster_security_group.id
}

output "cluster_endpoint" {
    description = "EKS Cluster endpoint"
    value = aws_eks_cluster.eks-cluster.endpoint
}

output "eks_cluster_token" {
    value = data.aws_eks_cluster_auth.cluster.token
}

output "eks_cluster_arn" {
    value = aws_eks_cluster.eks-cluster.arn
}

output "cluster_certificate_authority_data" {
    value = aws_eks_cluster.eks-cluster.certificate_authority.0.data
}

output "kubectl_config" {
    description = "kubectl config as generated by the module."
    value       = local_file.kubeconfig
    sensitive   = true
}

output "config_map_aws_auth" {
    description = "A kubernetes configuration to authenticate to this EKS cluster."
    value       = local_file.config_map_aws_auth
    sensitive   = true
}