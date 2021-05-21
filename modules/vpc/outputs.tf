output "vpc_id" {
  value = aws_vpc.vpc.id
  description = "VPC ID"
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.*.id
  description = "Public Subnet ID's"
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.*.id
  description = "Private Subnet ID's"
}