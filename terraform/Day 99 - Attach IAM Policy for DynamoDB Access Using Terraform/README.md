# Day 99: Attach IAM Policy for DynamoDB Access Using Terraform

## Objective
The objective was to provision a secure AWS DynamoDB table and implement access control using IAM roles and policies. I configured an IAM role with a read-only policy specifically scoped to a single DynamoDB table, ensuring that any service assuming this role can only perform non-destructive actions like `GetItem`, `Scan`, and `Query`.

## 1. IAM and DynamoDB Access Control

An **IAM Role** is an identity we can create in our account that has specific permissions. Unlike a user, it doesn't have a password or keys; instead, it is intended to be assumed by trusted entities (like an EC2 instance or a Lambda function).

### Policy Scoping and Least Privilege

For this task, I applied several security best practices:

1.  **Action Restriction:** I restricted the allowed actions to `dynamodb:GetItem`, `dynamodb:Scan`, and `dynamodb:Query`. These are "Read-Only" actions. I excluded actions like `PutItem` or `DeleteTable`, preventing the role from modifying or deleting data.
2.  **Resource Scoping:** Instead of using a wildcard `*` for the Resource field, I used the specific **ARN (Amazon Resource Name)** of the `xfusion-table`. This ensures that even if other DynamoDB tables exist in the account, this role cannot access them.
3.  **Trust Policy (AssumeRolePolicy):** I configured the IAM role with a trust relationship that allows the EC2 service (`ec2.amazonaws.com`) to assume the role.

### Decoupling with tfvars
I used a `terraform.tfvars` file to provide values to my variables. This separates the infrastructure logic from the environment-specific data, which is a standard practice for managing production environments.

## 2. Configured Variables and Values
I defined the required variables and their actual values across two files to maintain a modular configuration.

```hcl
# variables.tf
variable "KKE_TABLE_NAME" {}
variable "KKE_ROLE_NAME" {}
variable "KKE_POLICY_NAME" {}
```

```hcl
# terraform.tfvars
KKE_TABLE_NAME  = "xfusion-table"
KKE_ROLE_NAME   = "xfusion-role"
KKE_POLICY_NAME = "xfusion-readonly-policy"
```

## 3. Developed the Main Infrastructure Manifest
I created `main.tf` to provision the DynamoDB table, the IAM role, and the scoped read-only policy.

```hcl
# main.tf

# DynamoDB table
resource "aws_dynamodb_table" "xfusion_table" {
  name           = var.KKE_TABLE_NAME
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  tags = {
    Name = var.KKE_TABLE_NAME
  }
}


# IAM Policy with read-only access (GetItem, Scan, Query) to the DynamoDB table
resource "aws_iam_policy" "xfusion_readonly_policy" {
  name        = var.KKE_POLICY_NAME
  description = "Read-only access to DynamoDB table"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query"
      ]
      Resource = aws_dynamodb_table.xfusion_table.arn
    }]
  })
}


# IAM role allowed to access the DynamoDB table
resource "aws_iam_role" "xfusion_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = var.KKE_ROLE_NAME
  }
}


# Attach the IAM policy to the role
resource "aws_iam_role_policy_attachment" "xfusion" {
  role       = aws_iam_role.xfusion_role.name
  policy_arn = aws_iam_policy.xfusion_readonly_policy.arn
}
```

## 4. Configured Outputs
I created `outputs.tf` to provide confirmation of the resource names post-deployment.

```hcl
# outputs.tf
output "kke_dynamodb_table" { value = aws_dynamodb_table.xfusion_table.name }
output "kke_iam_role_name" { value = aws_iam_role.xfusion_role.name }
output "kke_iam_policy_name" { value = aws_iam_policy.xfusion_readonly_policy.name }
```

## 5. Deployment and Verification
I initialized the environment and applied the configuration.

```bash
terraform init
terraform apply -auto-approve
```

I verified the success of the task using the AWS CLI to inspect the table status and policy attachments.

```bash
# Verify the DynamoDB table is ACTIVE
aws dynamodb describe-table --table-name xfusion-table

# Verify the role
aws iam get-role --role-name xfusion-role

# Verify the policy is attached to the role
aws iam list-attached-role-policies --role-name xfusion-role

# Verify the policy actions are restricted to read-only
aws iam get-policy-version --policy-arn <Policy_ARN> --version-id v1
```

### Result
I verified that the `xfusion-table` is provisioned and the `xfusion-role` is correctly assuming the `xfusion-readonly-policy`. The policy successfully restricts access to only the `GetItem`, `Scan`, and `Query` actions for that specific table resource.

## Screenshot
![day-99-screenshot](day-99-screenshot.png)