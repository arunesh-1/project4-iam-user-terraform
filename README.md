# Project 4: IAM user automation with Terraform

Terraform creates a private S3 test bucket and an IAM user. An inline policy
grants the user permission to list that bucket and read its objects. The policy
JSON is stored in the `s3_read_policy` variable; `__BUCKET_ARN__` is replaced
with the test bucket ARN. Review any policy override carefully: it can grant
additional permissions. No login password or access keys are created.

## Deploy

Prerequisites: Terraform 1.5 or later, AWS CLI, and an authenticated AWS
identity with permissions to manage the specified IAM user and S3 bucket.
Creating resources may incur charges. Use an AWS account you control.

From PowerShell in this repository:

```powershell
aws sts get-caller-identity
$Account = aws sts get-caller-identity --query Account --output text
$Bucket = "project4-iam-test-$Account-$([guid]::NewGuid().ToString('N').Substring(0,8))"
terraform init
terraform plan -var "bucket_name=$Bucket" -out=tfplan
terraform apply tfplan
```

Keep the Terraform state private and do not commit it. The configuration uses
local state, so retain it for subsequent changes and cleanup.

## Test evidence

The simulator checks the user's IAM policy without creating access keys. It
does not replace a real S3 request or account for all live authorization
conditions such as bucket policies or organization restrictions. The CLI
identity needs `iam:SimulatePrincipalPolicy`.

```powershell
$UserArn = terraform output -raw user_arn
$Bucket = terraform output -raw bucket_name
$OtherBucket = "project4-other-bucket-$Account"

aws iam simulate-principal-policy --policy-source-arn $UserArn `
  --action-names s3:ListBucket --resource-arns "arn:aws:s3:::$Bucket" `
  --query "EvaluationResults[*].[EvalActionName,EvalResourceName,EvalDecision]" --output table

aws iam simulate-principal-policy --policy-source-arn $UserArn `
  --action-names s3:GetObject s3:PutObject `
  --resource-arns "arn:aws:s3:::$Bucket/test.txt" "arn:aws:s3:::$OtherBucket/test.txt" `
  --query "EvaluationResults[*].[EvalActionName,EvalResourceName,EvalDecision]" --output table
```

Expected: listing the test bucket and reading its object are `allowed`; writing
to it and reading or writing an object in the other bucket are `implicitDeny`.
Capture the output for the deliverable.

## Cleanup

After collecting evidence, remove any objects from the test bucket, then run
`terraform destroy -var "bucket_name=$Bucket"` from the same directory and
confirm the plan. Destroying removes the IAM user and bucket. Do not remove
the state file before destroying the resources.
