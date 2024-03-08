############################################################
#Create the eks  IAM role to allow EKS service to manage
#other AWS services
##########################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
    config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn:
      - ${aws_iam_role.eks-workernode-role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${aws_eks_cluster.eks-cluster.certificate_authority.0.data}
    server: ${aws_eks_cluster.eks-cluster.endpoint}
  name: ${aws_eks_cluster.eks-cluster.arn}
contexts:
- context:
    cluster: ${aws_eks_cluster.eks-cluster.arn}
    user: ${aws_eks_cluster.eks-cluster.arn}
  name: ${aws_eks_cluster.eks-cluster.arn}
current-context: ${aws_eks_cluster.eks-cluster.arn}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.eks-cluster.arn}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - ${var.region}
      - eks
      - get-token
      - --cluster-name
      - ${var.cluster_name}
      command: aws
KUBECONFIG
}

resource "aws_iam_role" "eks-iamcluster-role" {
    name = var.eks_iam_role_name

    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-iamcluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-iamcluster-role.name
}

##########################################
#Create the eks cluster
#########################################
resource "aws_eks_cluster" "eks-cluster" {
  name                      = var.cluster_name
  version                   = var.eks_cluster_version
  role_arn                  = aws_iam_role.eks-iamcluster-role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [aws_security_group.cluster_security_group.id]
    endpoint_private_access = var.eks_endpoint_private_access
    endpoint_public_access  = var.eks_endpoint_public_access
    public_access_cidrs     = var.eks_endpoint_public_access_cidr
  }

  tags = {
      Name                     = "${var.cluster_name}"
      "karpenter.sh/discovery" = var.cluster_name
    }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}

#########------SECURITY GROUPS---------------------##########

resource "aws_security_group" "cluster_security_group" {
  name_prefix = "${var.cluster_name}-sg"
  vpc_id      = var.eks_vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = var.cidr_blocks
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = var.cidr_blocks
  }

  tags = {
      "karpenter.sh/discovery" = var.cluster_name
    }
}


# ##############################################
# #eks workers roles
# #############################################
resource "aws_iam_role" "eks-workernode-role" {
  name = var.eks_workernode_iam_role_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {
    }
}

resource "aws_iam_role_policy" "eks_autoscaler_policy" {
    name = "${var.cluster_name}-autoscaler-policy"
    role = aws_iam_role.eks-workernode-role.name

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
          {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
          }
        ]
    })
}

# #################################################
# #eks worker role policies to attach
# #################################################
resource "aws_iam_role_policy_attachment" "eks-workernode-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-workernode-role.name
}

resource "aws_iam_role_policy_attachment" "eks-workernode-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-workernode-role.name
}

resource "aws_iam_role_policy_attachment" "eks-workernode-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-workernode-role.name
}

resource "aws_iam_role_policy_attachment" "eks-workernode-AmazonEFSReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess"
  role       = aws_iam_role.eks-workernode-role.name
}
# #####################################################
# #An instance profile is a container for an IAM role
# # that you can use to pass role information to an EC2 instance
# #when the instance starts.
# #####################################################
resource "aws_iam_instance_profile" "eks-workernode-profile" {
  name = "${var.cluster_name}-instanceprofile"
  role = aws_iam_role.eks-workernode-role.name
}


# ##############################################
# #Create the eks workers
# ##############################################
resource "aws_subnet" "nodes_private_subnet" {
    vpc_id                  = var.eks_vpc_id
    count                   = length(var.nodes_private_subnets_ids) != 0 ? 0 : "${length(var.nodes_private_subnets_cidr)}"
    cidr_block              = element(var.nodes_private_subnets_cidr, count.index)
    availability_zone       = element(var.azs, count.index)
    # map_public_ip_on_launch = var.public_ip_privatesubnet

    tags = {
        "karpenter.sh/discovery" = var.cluster_name
    }
}

resource "aws_route_table_association" "node_private" {
    count          = length(var.nodes_private_subnets_ids) != 0 ? 0 : "${length(var.nodes_private_subnets_cidr)}"
    subnet_id      = element(aws_subnet.nodes_private_subnet.*.id, count.index)
    route_table_id = var.private_route_id
}


#----------------------------------------#
#     Creating ssh key for worker-node.  #
#----------------------------------------#

resource "tls_private_key" "worker_node_key" {
    count = var.create_node_key == true ? 1 : 0
    algorithm = "RSA"
    rsa_bits = "4096"
}

resource "aws_key_pair" "worker_node_key_pair" {
    count      = var.create_node_key == true ? 1 : 0
    key_name   = "${var.cluster_name}-worker-node-key"
    public_key = tls_private_key.worker_node_key[0].public_key_openssh
}

#----------------------------------------#
#       Creating Default Worker ng       #
#----------------------------------------#

resource "aws_eks_node_group" "default-worker-nodes-group" {
  cluster_name           = aws_eks_cluster.eks-cluster.name
  node_group_name_prefix = var.eks_cluster_node_group_name
  node_role_arn          = aws_iam_role.eks-workernode-role.arn
  subnet_ids             = var.create_vpc == true ? aws_subnet.nodes_private_subnet.*.id : var.nodes_private_subnets_ids
  instance_types         = var.eks_instance_type
  disk_size              = var.disk_size
  ami_type               = var.ami_type
  capacity_type          = var.capacity_type

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.worker_node_key_pair[0].key_name
    source_security_group_ids = [aws_security_group.worker_security_group.id]
  }

#   launch_template {
#     name    = aws_launch_template.cluster.name
#     version = aws_launch_template.cluster.latest_version

#   }

  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_security_group.worker_security_group
  ]
  lifecycle {
    create_before_destroy = true
  }
  tags = {
      "Name"                                      = "${var.cluster_name}-workernode"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "karpenter.sh/discovery"                    = var.cluster_name
    }

}


# #########------SECURITY GROUPS---------------------##########
resource "aws_security_group" "worker_security_group" {
  name_prefix = "${var.cluster_name}-workersg"
  vpc_id      = var.eks_vpc_id /*!= "" ? var.vpc_id : aws_vpc.vpc[0].id*/

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = var.cidr_blocks
  }
  ingress {
    from_port = 0
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = var.cidr_blocks
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = var.cidr_blocks
  }

  tags = {
      "karpenter.sh/discovery" = var.cluster_name
    }
}


# #-----------------------------#
# #EKS Cluster kubeconfig       #
# #-----------------------------#
resource "local_file" "kubeconfig" {
  content  = local.kubeconfig
  filename = "/tmp/kube/${var.cluster_name}-kubeconfig"
}

# #-----------------------------#
# #EKS config map aws auth      #
# #-----------------------------#

resource "local_file" "config_map_aws_auth" {
  content  = local.config_map_aws_auth
  filename = "/tmp/kube/${var.cluster_name}-config_map_aws_auth"
}


data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks-cluster.id
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks-cluster.id
}
resource "kubernetes_config_map" "aws_auth_config_noc" {
    metadata {
      name = "aws-auth"
      namespace = "kube-system"
    }
    data = {
    mapRoles = <<YAML
- rolearn: ${aws_iam_role.eks-workernode-role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
  - system:bootstrappers
  - system:nodes
- userarn: ${data.aws_caller_identity.current.arn}
  username: ${data.aws_caller_identity.current.arn}
  groups:
  - system:masters
YAML
  }
}