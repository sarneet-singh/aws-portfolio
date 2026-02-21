output "s3_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = aws_s3_bucket.frontend.bucket
}

output "cloudfront_distribution_id" {
  description = "Cloudfront distribution ID"
  value       = aws_cloudfront_distribution.frontend-cf.id
}


output "cloudfront_domain_name" {
  description = "Cloudfront domain name "
  value       = aws_cloudfront_distribution.frontend-cf.domain_name
}


output "oac_id" {
  description = "OAC ID"
  value       = aws_cloudfront_origin_access_control.frontend-oac.id
}


output "dynamodb_table_id" {
  description = "Dynamo DB table name"
  value       = aws_dynamodb_table.contact_table.id
}

output "api_gateway_invoke_url" {
  description = "API Gateway Invoke URL"
  value       = aws_api_gateway_stage.contact_stage.invoke_url
}
