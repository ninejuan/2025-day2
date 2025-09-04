resource "aws_security_group" "wsi_ecs_sg" {
  name_prefix = "${var.name_prefix}-ecs-sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-sg"
  })
}

resource "aws_ecs_cluster" "wsi_cluster" {
  name = "${var.name_prefix}-app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-app-cluster"
  })
}

resource "aws_iam_role" "wsi_task_execution_role" {
  name = "${var.name_prefix}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-task-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "wsi_task_execution_role_policy" {
  role       = aws_iam_role.wsi_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "wsi_task_role" {
  name = "${var.name_prefix}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-task-role"
  })
}

resource "aws_ecs_task_definition" "wsi_task" {
  family                   = "${var.name_prefix}-app-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.wsi_task_execution_role.arn
  task_role_arn            = aws_iam_role.wsi_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.name_prefix}-app-cnt"
      image = "${var.ecr_repository_url}:latest"
      
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "FLASK_APP"
          value = "app.py"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.name_prefix}-app"
          awslogs-region        = "ap-southeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }

      essential = true
    }
  ])

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-app-fargate-task"
  })
}

resource "aws_cloudwatch_log_group" "wsi_log_group" {
  name              = "/ecs/${var.name_prefix}-app"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-app-logs"
  })
}

resource "aws_ecs_service" "wsi_service" {
  name            = "${var.name_prefix}-app-service"
  cluster         = aws_ecs_cluster.wsi_cluster.id
  task_definition = aws_ecs_task_definition.wsi_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.wsi_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.name_prefix}-app-cnt"
    container_port   = 5000
  }

  depends_on = [aws_iam_role_policy_attachment.wsi_task_execution_role_policy]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-app-service"
  })
}
