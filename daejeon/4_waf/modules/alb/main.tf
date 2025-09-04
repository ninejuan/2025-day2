resource "aws_security_group" "alb_sg" {
  name_prefix = "${var.name_prefix}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

resource "aws_lb" "xxe_alb" {
  name               = "xxe-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "xxe-alb"
  })
}

resource "aws_lb_target_group" "xxe_tg" {
  name        = "${var.name_prefix}-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-tg"
  })
}

resource "aws_lb_target_group_attachment" "xxe_tg_attachment" {
  target_group_arn = aws_lb_target_group.xxe_tg.arn
  target_id        = var.ec2_instance_id
  port             = 5000
}

resource "aws_lb_listener" "xxe_listener" {
  load_balancer_arn = aws_lb.xxe_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.xxe_tg.arn
  }
}
