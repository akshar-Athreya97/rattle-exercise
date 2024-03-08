variable "eks_iam_role_name" {}
variable "cluster_name" {}
variable "eks_cluster_version" {}
variable "cidr_blocks" {}
variable "eks_vpc_id" {}
variable "subnet_ids" {}
variable "eks_endpoint_private_access" {}
variable "eks_endpoint_public_access" {}
variable "eks_endpoint_public_access_cidr" {}
variable "eks_workernode_iam_role_name" {}
variable "nodes_private_subnets_ids" {}
variable "nodes_private_subnets_cidr" {}
variable "azs" {}
variable "private_route_id" {}
variable "eks_cluster_node_group_name" {}
variable "desired_capacity" {}
variable "eks_instance_type" {}
variable "disk_size" {}
variable "max_size" {}
variable "min_size" {}
variable "ec2_ssh_key" {}
variable "ami_type" {}
variable "create_vpc" {}
variable "region" {}
variable "manage_aws_auth" {}
variable "capacity_type" {
    type = string
    description = "EKS Node Group instance type Accepted value:- ON_DEMAND , SPOT"
}
variable "create_node_key" {
    description = "True to create nworker node key"
}