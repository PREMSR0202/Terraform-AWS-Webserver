output "loadbalancer_id" {
  value       = aws_lb.alb.id
  description = "Loadbalancer ID"
}

output "targetgroup_id" {
  value       = aws_lb_target_group.tg.id
  description = "Target Group ID"
}

output "securitygroup_id" {
  value = aws_security_group.sg_alb.id
  description = "Load Balancer Security Group Id"
}
