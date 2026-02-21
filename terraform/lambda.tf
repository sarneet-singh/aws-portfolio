# archive the lambda code into ZIP
data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "${path.root}/../backend/lambda_function.py"
  output_path = "${path.root}/../backend/lambda_function.zip"
}

# Create lambda function
resource "aws_lambda_function" "contact_handler" {
    function_name = "${var.lambda_function_name}"
    role = aws_iam_role.lambda_exec.arn
    runtime = "python3.13"
    handler = "lambda_function.lambda_handler"
    filename = data.archive_file.lambda_zip.output_path
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    environment {
      variables = {
        DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      }
    }

}

# Create CW log group for lambda logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
    name = "/aws/lambda/${aws_lambda_function.contact_handler.function_name}"
    retention_in_days = 14
    depends_on = [ aws_lambda_function.contact_handler ]
  
}