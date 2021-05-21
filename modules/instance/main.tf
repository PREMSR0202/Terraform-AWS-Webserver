terraform {
  required_version = ">=0.12"
}

resource "aws_efs_file_system" "efs" {
  encrypted        = true
  performance_mode = "generalPurpose"
  tags = {
    Name = "File-System"
  }
}

resource "aws_efs_mount_target" "efsmount" {
  count           = length(var.public_subnet_id)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.public_subnet_id[count.index]
  security_groups = [aws_security_group.sgefs.id]
}

resource "aws_launch_configuration" "configuration" {
  image_id        = var.image_id
  instance_type   = "t2.micro"
  key_name        = var.key
  security_groups = [aws_security_group.sginstance.id]
  user_data       = file("${path.module}/install_nginx.sh")
  depends_on = [
    aws_efs_file_system.efs,
    aws_efs_mount_target.efsmount
  ]
}

resource "aws_security_group" "sginstance" {
  name        = "SG-Instance"
  description = "Security Group For Instance"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sgefs" {
  name        = "SG-EFS"
  description = "Security Group For Elastic File System"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "sgruleefs" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sginstance.id
  security_group_id        = aws_security_group.sgefs.id
  depends_on = [
    aws_security_group.sginstance
  ]
}

resource "aws_security_group_rule" "sgruleinstance" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.loadbalancer_sg
  security_group_id        = aws_security_group.sginstance.id
  depends_on = [
    aws_security_group.sginstance
  ]
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier       = var.private_subnet_id.*
  name                      = "Webserver-AutoScaling"
  health_check_type         = "ELB"
  health_check_grace_period = 300
  launch_configuration      = aws_launch_configuration.configuration.name
  desired_capacity          = 2
  max_size                  = 5
  min_size                  = 1
  target_group_arns         = [var.targetgroup_arn]
  tags = [{
    Name = "Webserver-AutoScaling"
  }]
}
