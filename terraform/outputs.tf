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
