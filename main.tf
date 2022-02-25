terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_ecs_cluster" "service-cluster" {
  name = "service-cluster"
}

resource "aws_ecs_task_definition" "service-task" {
  family = "service-task"
  container_definitions = jsonencode(
    [
      {
        name : "service",
        image : "ghcr.io/denkoren/actions-experiments/service:latest",
        portMappings : [
          {
            containerPort: 80,
            hostPort: 80
          }
        ]
      }
    ]
  )
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  memory = 512
  cpu = 256
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
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

resource "aws_ecs_service" "myService" {
  name = "my-serv"
  cluster = aws_ecs_cluster.service-cluster.id
  task_definition = aws_ecs_task_definition.service-task.arn
  launch_type = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets = [aws_default_subnet.default_subnet_a.id]
    assign_public_ip = true
    security_groups = [aws_security_group.allow-all.id]
  }
}

resource "aws_default_vpc" "default_vpc" {}
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "eu-west-2a"
}
resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "eu-west-2b"
}
resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "eu-west-2c"
}

resource "aws_security_group" "allow-all" {
  ingress {
    self      = true
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
