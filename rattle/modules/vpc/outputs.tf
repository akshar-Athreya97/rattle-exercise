###--------VPC OUTPUTS--------###

output "vpc_id" {
    value = aws_vpc.vpc.*.id
}

output "private_subnets" {
    value = aws_subnet.private_subnet.*.id
}

output "public_subnets" {
    value = aws_subnet.public_subnet.*.id
}

output "private_route_id" {
    value = aws_route_table.private[0].id
}
# # output "security_groups" {
# #     value = aws_security_group.cluster_security_group.id
# # }

# output "vpc_security_groups" {
#     value = aws_security_group.vpc.id
# }

output "eks_subnets" {
    value = concat(aws_subnet.public_subnet.*.id,  aws_subnet.private_subnet.*.id)
}
