variable "availability_zones" {
  type        = list
  description = "Availability Zones for Load Balancer"
}

variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "subnet_id" {
  type        = list
  description = "Subnet Id's"
}
