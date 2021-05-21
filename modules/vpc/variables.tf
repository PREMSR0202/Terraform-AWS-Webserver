variable "vpc_cidr" {
  type = string
  description = "CIDR For VPC"
}

variable "public_subnet_cidr" {
  type = list
  description = "list of public subnet CIDR"
}

variable "private_subnet_cidr" {
  type = list
  description = "list of private subnet CIDR"
}

variable "availability_zones" {
  type = list
  description = "List of availability zones"
}

