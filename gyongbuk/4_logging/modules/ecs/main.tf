resource "aws_ecs_cluster" "main" {
  name = "skills-log-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "skills-log-cluster"
  }
}


resource "aws_iam_role" "ecs_task_execution" {
  name = "skills-log-ecs-task-execution-role"

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
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_custom" {
  name = "skills-log-ecs-task-execution-custom"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "skills-log-ecs-task-role"

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
}

resource "aws_iam_role_policy" "ecs_task_logs" {
  name = "skills-log-ecs-task-logs"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "app" {
  family                   = "skills-log-app-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${var.ecr_app_repository_url}:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          tag = "app-logs"
        }
      }

      environment = [
        {
          name  = "FLASK_ENV"
          value = "production"
        }
      ]

      dependsOn = [
        {
          containerName = "log_router"
          condition     = "START"
        }
      ]
    },
    {
      name      = "log_router"
      image     = "${var.ecr_firelens_repository_url}:latest"
      essential = true

      environment = [
        {
          name  = "FLB_LOG_LEVEL"
          value = "debug"
        }
      ]

      firelensConfiguration = {
        type = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
          config-file-type        = "file"
          config-file-value       = "/fluent-bit/etc/extra.conf"
        }
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.cloudwatch_log_group_name
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "firelens"
        }
      }
    }
  ])

  tags = {
    Name = "skills-log-app-td"
  }
}

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  health_check_grace_period_seconds = 30

  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "app"
    container_port   = 5000
  }

  depends_on = [aws_ecs_task_definition.app]

  tags = {
    Name = "skills-log-app-service"
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "null_resource" "force_ecs_deployment" {
  depends_on = [aws_ecs_service.app]

  triggers = {
    app_image_pushed      = var.app_image_pushed
    firelens_image_pushed = var.firelens_image_pushed
  }

  provisioner "local-exec" {
    command = <<-EOF
      aws ecs update-service \
        --cluster ${aws_ecs_cluster.main.name} \
        --service ${aws_ecs_service.app.name} \
        --force-new-deployment \
        --region ${data.aws_region.current.name}
    EOF
  }
}

data "aws_region" "current" {}
