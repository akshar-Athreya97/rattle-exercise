module "docker-builder" {
    source                     = "./modules/docker-builder"
    image_name                 = var.image_name
    dockerfile_path            = var.dockerfile_path
}

module "vpc" {
    source                     = "./modules/vpc"
    cluster_name               = var.cluster_name
    create_vpc                 = var.create_vpc
    vpc_name                   = var.vpc_name
    vpc_cidr                   = var.vpc_cidr
    azs                        = var.azs
    public_subnets_cidr        = var.public_subnets_cidr
    public_subnets_ids         = var.public_subnets_ids
    private_subnets_cidr       = var.private_subnets_cidr
    private_subnets_ids        = var.private_subnets_ids
    additional_cidr_block      = var.additional_cidr_block
    # cidr_blocks                = var.cidr_blocks
    vpc_id                     = var.vpc_id
    destination_cidr_block     = var.destination_cidr_block
    region                     = var.region
    map_public_ip_on_launch    = var.map_public_ip_on_launch
    igw_name                   = var.igw_name
    nat_name                   = var.nat_name
}

module "eks-cluster" {
    source                          = "./modules/eks-cluster"
    count                           = var.create_eks-cluster ? 1 : 0
    azs                             = var.azs
    create_vpc                      = var.create_vpc
    eks_iam_role_name               = "${var.cluster_name}-cluster-role"
    cluster_name                    = "${var.cluster_name}-eks-cluster"
    eks_cluster_version             = var.eks_cluster_version
    cidr_blocks                     = var.cidr_blocks
    eks_vpc_id                      = module.vpc.vpc_id.0
    subnet_ids                      = module.vpc.eks_subnets
    eks_endpoint_private_access     = var.eks_endpoint_private_access
    eks_endpoint_public_access      = var.eks_endpoint_public_access
    eks_endpoint_public_access_cidr = var.eks_endpoint_public_access_cidr
    eks_workernode_iam_role_name    = "${var.cluster_name}-worker-role"
    nodes_private_subnets_cidr      = var.worker_nodes_private_subnets_cidr
    nodes_private_subnets_ids       = var.worker_nodes_private_subnets_ids
    private_route_id                = module.vpc.private_route_id
    eks_cluster_node_group_name     = "${var.cluster_name}-nodegroup"
    desired_capacity                = var.desired_capacity
    ami_type                        = var.ami_type
    eks_instance_type               = "${var.capacity_type == "SPOT" ? var.eks_instance_type_spot : var.eks_instance_type}"
    disk_size                       = var.disk_size
    max_size                        = var.max_size
    min_size                        = var.min_size
    ec2_ssh_key                     = var.ec2_ssh_key
    region                          = var.region
    manage_aws_auth                 = true
    depends_on                      = [module.vpc]
    capacity_type                   = var.capacity_type
    create_node_key                 = var.create_node_key
}

module "kubernetes" {
    source = "./modules/kubernetes"
    eks_cluster_arn = module.eks-cluster[0].eks_cluster_arn
    exercise_image = module.docker-builder.pushed_image
}