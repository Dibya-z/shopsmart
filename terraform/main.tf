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
