terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────
# S3 Bucket
# ─────────────────────────────────────────────
resource "aws_s3_bucket" "shopsmart" {
  bucket = "shopsmart-dibyajyoti-bucket"

  tags = {
    Project     = "ShopSmart"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ─────────────────────────────────────────────
# Versioning
# ─────────────────────────────────────────────
resource "aws_s3_bucket_versioning" "shopsmart" {
  bucket = aws_s3_bucket.shopsmart.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ─────────────────────────────────────────────
# Server-Side Encryption (AES-256)
# ─────────────────────────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "shopsmart" {
  bucket = aws_s3_bucket.shopsmart.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ─────────────────────────────────────────────
# Block All Public Access
# ─────────────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "shopsmart" {
  bucket = aws_s3_bucket.shopsmart.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─────────────────────────────────────────────
# ECR Repository (Docker Image Registry)
# ─────────────────────────────────────────────
resource "aws_ecr_repository" "shopsmart_backend" {
  name                 = "shopsmart-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project   = "ShopSmart"
    ManagedBy = "Terraform"
  }
}

# ─────────────────────────────────────────────
# ECS Cluster
# ─────────────────────────────────────────────
resource "aws_ecs_cluster" "shopsmart" {
  name = "shopsmart-cluster"

  tags = {
    Project   = "ShopSmart"
    ManagedBy = "Terraform"
  }
}

# ─────────────────────────────────────────────
# IAM Execution Role (allows ECS to pull from ECR)
# ─────────────────────────────────────────────
data "aws_iam_role" "ecs_task_execution_role" {
  name = "LabRole"
}

# ─────────────────────────────────────────────
# Default VPC + Subnets (reuse existing network)
# ─────────────────────────────────────────────
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ─────────────────────────────────────────────
# Security Group (allow inbound on port 5000)
# ─────────────────────────────────────────────
resource "aws_security_group" "shopsmart_backend" {
  name        = "shopsmart-backend-sg"
  description = "Allow inbound traffic to ShopSmart backend"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 5000
    to_port     = 5000
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
    Project   = "ShopSmart"
    ManagedBy = "Terraform"
  }
}

# ─────────────────────────────────────────────
# ECS Task Definition
# ─────────────────────────────────────────────
resource "aws_ecs_task_definition" "shopsmart_backend" {
  family                   = "shopsmart-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "shopsmart-backend"
      image     = "${aws_ecr_repository.shopsmart_backend.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "PORT"
          value = "5000"
        },
        {
          name  = "DATABASE_URL"
          value = "file:./dev.db"
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://localhost:5000/api/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 40
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/shopsmart-backend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])

  tags = {
    Project   = "ShopSmart"
    ManagedBy = "Terraform"
  }
}

# ─────────────────────────────────────────────
# ECS Service (runs the task on Fargate)
# ─────────────────────────────────────────────
resource "aws_ecs_service" "shopsmart_backend" {
  name            = "shopsmart-backend-service"
  cluster         = aws_ecs_cluster.shopsmart.id
  task_definition = aws_ecs_task_definition.shopsmart_backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.shopsmart_backend.id]
    assign_public_ip = true
  }

  # Allow Terraform to update the service when a new image is deployed
  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Project   = "ShopSmart"
    ManagedBy = "Terraform"
  }
}

