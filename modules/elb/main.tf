terraform {
  required_version = ">=0.12"
}

locals {
  ingress_rule = [{
    port        = 80
    description = "HTTP Port"
    }
  ]
}

resource "aws_security_group" "sg_alb" {
  name        = "SG-Alb"
  description = "Security Group For Load Balancer"
  vpc_id      = var.vpc_id
  dynamic "ingress" {
    for_each = local.ingress_rule
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Alb"
  }
}

resource "aws_lb" "alb" {
  name               = "Application-Load-Balancer"
  load_balancer_type = "application"
  internal           = false
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = var.subnet_id.*
  tags = {
    Name = "ALB"
  }
}

resource "aws_lb_target_group" "tg" {
  vpc_id      = var.vpc_id
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 30
    path     = "/"
  }
  tags = {
    Name = "Target-Group"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
