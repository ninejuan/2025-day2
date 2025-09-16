resource "aws_vpclattice_service_network" "main" {
  name      = "skills-app-service-network"
  auth_type = "NONE"

  tags = {
    Name = "skills-app-service-network"
  }
}

resource "aws_vpclattice_service_network_vpc_association" "consumer" {
  vpc_identifier             = var.consumer_vpc_id
  service_network_identifier = aws_vpclattice_service_network.main.id
  
  tags = {
    Name = "consumer-vpc-association"
  }
}

resource "aws_vpclattice_service_network_vpc_association" "service" {
  vpc_identifier             = var.service_vpc_id
  service_network_identifier = aws_vpclattice_service_network.main.id
  
  tags = {
    Name = "service-vpc-association"
  }
}

resource "aws_vpclattice_service" "main" {
  name      = "skills-app-service"
  auth_type = "NONE"

  tags = {
    Name = "skills-app-service"
  }
}

resource "aws_vpclattice_service_network_service_association" "main" {
  service_identifier         = aws_vpclattice_service.main.id
  service_network_identifier = aws_vpclattice_service_network.main.id

  tags = {
    Name = "service-association"
  }
}

resource "aws_vpclattice_target_group" "alb" {
  name = "skills-alb-tg"
  type = "ALB"

  config {
    vpc_identifier = var.service_vpc_id
    port           = 80
    protocol       = "HTTP"
  }

  tags = {
    Name = "skills-alb-tg"
  }
}

resource "aws_vpclattice_target_group_attachment" "alb" {
  target_group_identifier = aws_vpclattice_target_group.alb.id
  
  target {
    id = var.app_alb_arn
  }
}

resource "aws_vpclattice_listener" "main" {
  name               = "skills-app-listener"
  protocol           = "HTTP"
  service_identifier = aws_vpclattice_service.main.id

  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.alb.id
      }
    }
  }

  tags = {
    Name = "skills-app-listener"
  }
}
