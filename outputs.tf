output "user_arn" {
  description = "IAM user ARN for policy simulation."
  value       = aws_iam_user.reader.arn
}

output "bucket_name" {
  description = "Name of the dedicated S3 test bucket."
  value       = aws_s3_bucket.test.id
}
