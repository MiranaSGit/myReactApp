resource "aws_ecs_cluster" "demo-cluster" {
  name = "demo-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    "Name" : "ECS-cluster-Demo"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "apptask-demo"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  task_role_arn = aws_iam_role.task_role.arn

  container_definitions = <<EOF
[
  {
    "name": "${var.container_name}",
    "image": "${var.image}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "app" {
  name            = "demo-service"
  cluster         = aws_ecs_cluster.demo-cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.replicas

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs-sg.id]
    subnets          = data.aws_subnet.subnet-ids.*.id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main-tg.id
    container_name   = var.container_name
    container_port   = var.container_port
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  depends_on = [aws_alb_listener.listener_http]

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    "Name" : "ECS-service"
  }
}

resource "aws_iam_role" "task_role" {
  name               = "task_role"
  assume_role_policy = data.aws_iam_policy_document.app_role_assume_role_policy.json
}

data "aws_iam_policy_document" "app_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "app_policy" {
  name   = "app_policy"
  role   = aws_iam_role.task_role.id
  policy = data.aws_iam_policy_document.app_policy.json
}

data "aws_iam_policy_document" "app_policy" {
  statement {
    actions = [
      "ecs:DescribeClusters",
    ]

    resources = [
      aws_ecs_cluster.demo-cluster.arn,
    ]
  }
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
