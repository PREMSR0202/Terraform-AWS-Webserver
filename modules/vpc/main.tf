terraform {
  required_version = ">=0.12"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[count.index]
  tags = {
    Name = "Public-${count.index}"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr[count.index]
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones[count.index]
  tags = {
    Name = "Private-${count.index}"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_route_table" "private_route_table" {
  count  = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Priavte-Route-Table${count.index}"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
  depends_on = [
    aws_route_table.public_route_table
  ]
}

resource "aws_route_table_association" "private_rta" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
  depends_on = [
    aws_route_table.private_route_table
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Internet-GateWay"
  }
}

resource "aws_eip" "elastic_ip" {
  count = length(var.private_subnet_cidr)
  vpc   = true
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnet_cidr)
  allocation_id = aws_eip.elastic_ip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on = [
    aws_internet_gateway.igw,
    aws_eip.elastic_ip
  ]
  tags = {
    Name = "Public-Nat-${count.index}"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_route" "private_route" {
  count                  = length(var.private_subnet_cidr)
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway[count.index].id
  depends_on = [
    aws_internet_gateway.igw
  ]
}




