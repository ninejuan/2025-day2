resource "aws_security_group" "endpoints_sg" {
  name        = "${var.prefix}-endpoints-sg"
  description = "${var.prefix}-endpoints-sg"
  vpc_id      = module.app_vpc.vpc_id

  ingress {
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

  tags = {
    Name = "${var.prefix}-vpc-endpoints-sg"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  subnet_ids          = [aws_subnet.app_subnet_a.id, aws_subnet.app_subnet_b.id]
  security_group_ids  = [aws_security_group.endpoints_sg.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "ssm:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.prefix}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = module.app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  subnet_ids          = [aws_subnet.app_subnet_a.id, aws_subnet.app_subnet_b.id]
  security_group_ids  = [aws_security_group.endpoints_sg.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "ssmmessages:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.prefix}-ssm-messages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id              = module.app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  route_table_ids     = []
  subnet_ids          = [aws_subnet.app_subnet_a.id, aws_subnet.app_subnet_b.id]
  security_group_ids  = [aws_security_group.endpoints_sg.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "ec2messages:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.prefix}-ec2-messages-endpoint"
  }
}
