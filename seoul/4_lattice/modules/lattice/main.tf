resource "aws_vpclattice_service_network" "main" {
  name = var.service_network_name
  
  tags = var.tags
}

resource "aws_vpclattice_target_group" "main" {
  name = var.target_group_name
  type = var.target_group_type

  config {
    port = 80
    protocol = "HTTP"
    vpc_identifier = var.vpc_id
    
    health_check {
      enabled = true
      health_check_interval_seconds = 30
      health_check_timeout_seconds = 5
      healthy_threshold_count = 5
      unhealthy_threshold_count = 2
      matcher {
        value = "200-399"
      }
      path = "/api"
      protocol = "HTTP"
      protocol_version = "HTTP1"
    }
  }

  tags = var.tags
}

# Target Group에 target을 등록
resource "aws_vpclattice_target_group_attachment" "main" {
  target_group_identifier = aws_vpclattice_target_group.main.id
  
  target {
    id   = var.target_instance_id
    port = 80
  }
}

resource "aws_vpclattice_service" "main" {
  name = var.service_name
  
  tags = var.tags
}

resource "aws_vpclattice_listener" "main" {
  name               = var.listener_name
  protocol           = var.listener_protocol
  port               = var.listener_port
  service_identifier = aws_vpclattice_service.main.id

  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.main.id
        weight                  = 100
      }
    }
  }
}

resource "aws_vpclattice_service_network_vpc_association" "vpc_a_association" {
  service_network_identifier = aws_vpclattice_service_network.main.id
  vpc_identifier            = var.vpc_a_id
  
  security_group_ids = [var.vpc_a_security_group_id]
}

resource "aws_vpclattice_service_network_vpc_association" "vpc_b_association" {
  service_network_identifier = aws_vpclattice_service_network.main.id
  vpc_identifier            = var.vpc_b_id
  
  security_group_ids = [var.vpc_b_security_group_id]
}

resource "aws_vpclattice_service_network_service_association" "service_association" {
  service_network_identifier = aws_vpclattice_service_network.main.id
  service_identifier         = aws_vpclattice_service.main.id
}
