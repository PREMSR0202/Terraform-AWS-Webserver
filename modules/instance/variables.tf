variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "public_subnet_id" {
  type        = list
  description = "Public Subnet Id's"
}

variable "private_subnet_id" {
  type        = list
  description = "Private Subnet Id's"
}

variable "key" {
  type = string
  description = "Private Key Name for Instance"
}

variable "image_id" {
  type = string
  description = "Image Id for Instance"
}

variable "loadbalancer_sg" {
  type = string
  description = "Security Group Id of Load Balancer"
}

variable "targetgroup_arn" {
  type = string
  description = "Target Group Arn for Auto Scaling Group"
}