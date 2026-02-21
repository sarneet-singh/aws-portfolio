# DynamoDB table for storing the contact form details
resource "aws_dynamodb_table" "contact_table" {
    name = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "email"
    range_key = "timestamp"
    attribute {
      name = "email"
      type = "S"
    }
    attribute {
      name = "timestamp"
      type = "S"
    }

    point_in_time_recovery {
      enabled = true
    }
    server_side_encryption {
      enabled = true
    }
    lifecycle {
      prevent_destroy = true
    }

  
}