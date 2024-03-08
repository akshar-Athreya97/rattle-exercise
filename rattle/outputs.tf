output "helloworld_image" {
    value = module.docker-builder.pushed_image
}
output "vpc_id" {
    value = module.vpc.vpc_id
}

output "private_subnets" {
    value = module.vpc.private_subnets
}

output "nodes_private_subnets" {
    value = module.vpc.private_subnets
}

output "public_subnets" {
    value = module.vpc.public_subnets
}

output "cluster_id" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].cluster_id : null
}

output "cluster_endpoint" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].cluster_endpoint : null
}

output "cluster_certificate_authority_data" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].cluster_certificate_authority_data : null
}

output "kubectl_config" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].kubectl_config : null
    sensitive = true
}

output "config_map_aws_auth" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].config_map_aws_auth : null
    sensitive = true
}

output "cluster_name" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].cluster_name : null
}

output "cluster_iam_role_name" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].cluster_iam_role_name : null
}

output "cluster_iam_role_arn" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].cluster_iam_role_arn : null
}

output "worker_iam_role_name" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].worker_iam_role_name : null
}

output "worker_iam_role_arn" {
    value = length(module.eks-cluster[*]) > 0 ? module.eks-cluster[*].worker_iam_role_arn : null
}

output "loadbalancer_ep" {
    value = module.kubernetes.loadbalancer_ep
}