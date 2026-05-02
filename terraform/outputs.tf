output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.shopsmart.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.shopsmart.arn
}

output "bucket_region" {
  description = "AWS region the bucket was created in"
  value       = aws_s3_bucket.shopsmart.region
}

output "ecr_repository_url" {
  description = "URL of the ECR repository to push Docker images to"
  value       = aws_ecr_repository.shopsmart_backend.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.shopsmart.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.shopsmart_backend.name
}
