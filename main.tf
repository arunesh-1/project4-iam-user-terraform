terraform {
  required_version = ">= 1.5.0, < 2.0.0"

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

resource "aws_s3_bucket" "test" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "test" {
  bucket = aws_s3_bucket.test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "reader" {
  name = var.iam_user_name
}

resource "aws_iam_user_policy" "s3_read" {
  name   = "project4-s3-read"
  user   = aws_iam_user.reader.name
  policy = replace(var.s3_read_policy, "__BUCKET_ARN__", aws_s3_bucket.test.arn)
}
