###-----VPC VARIABLES-----####
variable "create_vpc" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "additional_cidr_block" {}
variable "azs" {}
variable "region" {}
variable "public_subnets_cidr" {}
variable "private_subnets_cidr" {}
variable "public_subnets_ids" {}
variable "private_subnets_ids" {}
variable "destination_cidr_block" {}
variable "vpc_name" {}
variable "cluster_name" {}
variable "map_public_ip_on_launch" {}
variable "igw_name" {}
variable "nat_name" {}
