variable "image_name" {
    description = "Name of docker image to be built"
    default = "registry-1.docker.io/akshar1/rattle-exercise:v1.4.x"
}

variable "dockerfile_path" {
    description = "Path to dockerfile"
    default = "./modules/docker-builder/Dockerfile"
}

###############################
##                           ##
##      VPC Varaiables       ##
##                           ##
###############################

variable "region" {
    description = "AWS Region"
    default = ["ap-south-1"]
}

variable "cluster_name" {
    description = "EKS cluster name"
}

variable "azs" {
    description = "Availabilty zones"
    default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "create_vpc" {
    description = "Create VPC or not"
}

variable "vpc_name" {
    description = "VPC Name"
    default = ""
}

variable "vpc_cidr" {
    description = "CIDR block for vpc"
}

variable "vpc_id" {
    description = "VPC ID of an existing VPC"
    default = ""
}

variable "cidr_blocks" {
    description = "CIDR Blocks to be passed in different security groups"
    default = ["10.0.0.0/16", "0.0.0.0/0"]
}

variable "public_subnets_cidr" {
}
variable "public_subnets_ids" {
    default = ""
}
variable "private_subnets_cidr" {
    default = ["10.0.4.0/24"]
}
variable "private_subnets_ids" {
}
variable "destination_cidr_block" {
}

variable "additional_cidr_block" {
}

variable "map_public_ip_on_launch" {
    default = false
}

variable "igw_name" {
}

variable "nat_name" {
}


#------------------------------------#
#           EKS Variables            #
#------------------------------------#

variable "create_eks-cluster" {
    description = "True to create EKS cluster"
}

variable "eks_cluster_version" {
}


variable "eks_endpoint_private_access" {
    default = true
}

variable "eks_endpoint_public_access" {
    default = false
}

variable "eks_endpoint_public_access_cidr" {
    default = ["0.0.0.0/0"]
}

variable "worker_nodes_private_subnets_cidr" {
    default = []
}

variable "worker_nodes_private_subnets_ids" {
    default = []
}

variable "desired_capacity" {
    description = "Desired node capacity"
    default = 2
}

variable "eks_instance_type" {
    description = "EKS Instance type"
    type = list
    default = ["t3.xlarge"]
}
variable "disk_size" {
    description = "EKS Instance disk size"
}

variable "ami_type" {
    description = "EKS Instance AMI"
}

variable "max_size" {
    description = "EKS Node group max size"
}

variable "min_size" {
    description = "EKS Instance min size"
}

variable "ec2_ssh_key" {
    default = "dev-kp"
}

variable "capacity_type" {
    type = string
    description = "EKS Node Group instance type Accepted value:- ON_DEMAND , SPOT"
}

variable "eks_instance_type_spot" {
    description = "EKS list instance type to be definded when capacity_type is SPOT"
    type = list
    default = ["t3.xlarge","t3a.xlarge","t3a.large"]
}

variable "create_node_key" {
    default = true
}

# variable "eks_cluster_arn" {
#     description = "ARN of created cluster"
#     default = ""
# }

# variable "exercise_image" {
#     description = "Docker image pushed"
#     default = ""
# }