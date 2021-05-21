output "vpc_id" {
  value = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
  description = "Public Subnet ID's"
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
  description = "Private Subnet ID's"
  sensitive = true
}

output "loadbalancer_id" {
  value = module.elb.loadbalancer_id
  description = "Loadbalancer ID"
}

output "targetgroup_id" {
  value = module.elb.targetgroup_id
  description = "Target Group ID"
}

output "securitygroup_id" {
  value = module.elb.securitygroup_id
  description = "Load Balancer Security Group Id"
}
