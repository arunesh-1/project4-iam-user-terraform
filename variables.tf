variable "aws_region" {
  description = "AWS region for the test bucket."
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Globally unique name for the dedicated S3 test bucket."
  type        = string
}

variable "iam_user_name" {
  description = "Name of the IAM user created for this project."
  type        = string
  default     = "project4-s3-reader"
}

variable "s3_read_policy" {
  description = "IAM policy JSON; __BUCKET_ARN__ is replaced with the test bucket ARN."
  type        = string
  default     = <<-JSON
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "ListTestBucket",
          "Effect": "Allow",
          "Action": ["s3:ListBucket"],
          "Resource": "__BUCKET_ARN__"
        },
        {
          "Sid": "ReadTestObjects",
          "Effect": "Allow",
          "Action": ["s3:GetObject"],
          "Resource": "__BUCKET_ARN__/*"
        }
      ]
    }
  JSON

  validation {
    condition     = can(jsondecode(var.s3_read_policy))
    error_message = "s3_read_policy must be valid JSON."
  }
}
