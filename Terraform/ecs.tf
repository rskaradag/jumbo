resource "aws_ecs_cluster" "jumbo" {
  name = "${var.app_name}-cluster"
}

resource "aws_security_group" "jumbo_ecs_sg" {
  name        = "${var.app_name}-sg-fargate"
  description = "Allow HTTP,EFS inbound traffic"
  vpc_id      = aws_vpc.jumbo_vpc.id

  ingress {
    protocol    = "6"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "6"
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_ecs_service" "jumbo_service" {
  name                = "${var.app_name}-service"
  cluster             = aws_ecs_cluster.jumbo.id
  task_definition     = aws_ecs_task_definition.jumbo_task.arn
  desired_count       = 1
  launch_type         = "FARGATE"
  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.jumbo_ecs_sg.id]
    subnets          = [aws_subnet.private[0].id, aws_subnet.private[1].id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = var.app_name
    container_port   = 80
  }

  depends_on = [aws_lb_listener.lb_listener]
}

resource "aws_ecs_task_definition" "jumbo_task" {
  family                   = "${var.app_name}-task-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  container_definitions    = <<DEFINITION
[
  {
      "image": "600210043783.dkr.ecr.eu-central-1.amazonaws.com/myjumborepo:latest",
      "name": "${var.app_name}",
      "portMappings": [
          {
              "hostPort": 80,
              "containerPort": 80,
              "protocol": "tcp"
          }
      ],
      "essential": true,
      "mountPoints": [
          {
              "containerPath": "/mnt/efs",
              "sourceVolume": "efs"
          }
      ],
      "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.app_name}-logs-group",
        "awslogs-region": "eu-central-1",
        "awslogs-stream-prefix": "ecs",
        "awslogs-create-group": "true"
      }
    }
  }
]
DEFINITION

  volume {
    name = "efs"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.jumbo_efs.id
      root_directory     = "/mnt/efs"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.app.id
        iam             = "ENABLED"
      }
    }
  }


  runtime_platform {
    operating_system_family = "LINUX"
  }


}