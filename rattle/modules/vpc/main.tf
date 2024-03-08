
/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr

    tags = {
        "Name" = var.vpc_name
        "kubernetes.io/cluster/${var.cluster_name}" = var.cluster_name
    }
}

# /*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
    count  = var.create_vpc == true ? 1 : 0
    vpc_id =  "${aws_vpc.vpc.id}"/*var.vpc_id != "" ? var.vpc_id :*/

    tags = {
        "Name" = "${var.igw_name}"
    }
}

# /* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
    count      = var.create_vpc == true ? 1 : 0
    domain     = "vpc"
    depends_on = [aws_internet_gateway.ig]
    lifecycle {
        ignore_changes = [tags]
    }
}

/* NAT */
resource "aws_nat_gateway" "nat" {
    count         = var.create_vpc == true ? 1 : 0
    allocation_id = aws_eip.nat_eip[0].id

    subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
    depends_on    = [aws_internet_gateway.ig]

    tags = {
        "Name" = "${var.nat_name}"
    }
}

# /* Public subnet */
resource "aws_subnet" "public_subnet" {
    vpc_id                  = var.vpc_id != "" ? var.vpc_id : "${aws_vpc.vpc.id}"
    count                   = var.create_vpc == true ? length(var.public_subnets_cidr) : 0
    cidr_block              = element(var.public_subnets_cidr, count.index)
    availability_zone       = element(var.azs, count.index)
    map_public_ip_on_launch = var.map_public_ip_on_launch

    tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                    = "1"
        "karpenter.sh/discovery"                    = var.cluster_name
    }
}

# /* Private subnet */
resource "aws_subnet" "private_subnet" {
    vpc_id                  = var.vpc_id != "" ? var.vpc_id : "${aws_vpc.vpc.id}"
    count                   = length(var.private_subnets_ids) != 0 ? 0 : "${length(var.private_subnets_cidr)}"
    cidr_block              = element(var.private_subnets_cidr, count.index)
    availability_zone       = element(var.azs, count.index)

    tags = {
            "kubernetes.io/cluster/${var.cluster_name}" = "shared"
            "karpenter.sh/discovery"                    = var.cluster_name
    }
}

# /* Routing table for private subnet */
resource "aws_route_table" "private" {
    count  = var.create_vpc == true ? 1 : 0
    vpc_id = var.vpc_id != "" ? var.vpc_id : "${aws_vpc.vpc.id}"
}

# /* Routing table for public subnet */
resource "aws_route_table" "public" {
    count  = var.create_vpc == true ? 1 : 0
    vpc_id = var.vpc_id != "" ? var.vpc_id : "${aws_vpc.vpc.id}"

    tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = var.cluster_name
    }
}

resource "aws_route" "public_internet_gateway" {
    count                  = var.create_vpc == true ? 1 : 0
    route_table_id         = aws_route_table.public[0].id
    destination_cidr_block = var.destination_cidr_block
    gateway_id             = aws_internet_gateway.ig[0].id
}

resource "aws_route" "private_nat_gateway" {
    count                  = length(var.private_subnets_ids) != 0 ? 0 : 1
    route_table_id         = aws_route_table.private[0].id
    destination_cidr_block = var.destination_cidr_block
    nat_gateway_id         = aws_nat_gateway.nat[0].id
}

# /* Route table associations */
resource "aws_route_table_association" "public" {
    count          = var.create_vpc == true ? length(var.public_subnets_cidr) : 0
    subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
    route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
    count          = length(var.private_subnets_ids) != 0 ? 0 : "${length(var.private_subnets_cidr)}"
    subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
    route_table_id = aws_route_table.private[0].id
}