variable "aws_region" {
    type = string
    default = "ap-south-1"
    description = "Default AWS Region"
  
}

variable "project_name" {
    type = string
    default = "aws-portfolio"
    description = "Project name and repo name"  
  
}

variable "environment" {
    type = string
    default = "dev"
    description = "Default to dev environment"  
  
}

variable "s3_bucket_name" {
    type = string
    description = "S3 bucket name, globally unique"  
}

variable "dynamodb_table_name" {
    type = string
    default = "portfolio-contact"
    description = "DDB table name"  
}

variable "lambda_function_name" {
    type = string
    default = "portfolio-contact-handler"
    description = "Lambda function name"  

}

variable "tags" {
    type = map(string)
    description = "Default tags applied to all resources"
    default = {}
  
}
variable "acm_certificate_arn" {
    type = string
   description = "ACM Certificate ARN"  
}