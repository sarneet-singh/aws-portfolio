# Lambda exec role trust policy
data "aws_iam_policy_document" "lambda_assume_role" {
    statement {
      sid = "LambdaAssumeRole"
      effect = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }
    }
}

# Lambda exec role
resource "aws_iam_role" "lambda_exec" {
    name = "${var.project_name}-${var.environment}-lambda-exec"
    assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# DynamoDB write policy data source

data "aws_iam_policy_document" "dynamodb_write" {
    statement {
      sid = "WriteOnly"
      actions = [ "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem" ]
      resources = [ aws_dynamodb_table.contact_table.arn ]
    }
}

# DynamoDB managed policy
resource "aws_iam_policy" "dynamodb_write" {
    name = "${var.project_name}-${var.environment}-dynamodb-policy"
    description = "Policy for DynamoDB writes"
    policy = data.aws_iam_policy_document.dynamodb_write.json
  
}

# Attach DynamoDB policy to role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_write" {
    role = aws_iam_role.lambda_exec.name
    policy_arn = aws_iam_policy.dynamodb_write.arn

  
}
# get current caller details
data "aws_caller_identity" "current" {}


#  CloudWatch Logs policy data source
data "aws_iam_policy_document" "lambda_logs" {
    statement {
      actions = [ "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents" ]
      resources = [
        "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
]
}
}

#CloudWatch Logs managed policy
resource "aws_iam_policy" "lambda_logs" {
    name = "${var.project_name}-${var.environment}-cloudwatch-logs-policy"
    description = "Policy for CW logs"
    policy = data.aws_iam_policy_document.lambda_logs.json

  
}

# Attach Logs policy to role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role = aws_iam_role.lambda_exec.name
    policy_arn = aws_iam_policy.lambda_logs.arn
  
}