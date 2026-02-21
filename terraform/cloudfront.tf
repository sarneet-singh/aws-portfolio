resource "aws_cloudfront_origin_access_control" "frontend-oac" {
    name = "${var.project_name}-${var.environment}-oac"
    origin_access_control_origin_type = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
  
}

resource "aws_cloudfront_distribution" "frontend-cf" {
    enabled = true
    default_root_object = "index.html"
    origin {
        origin_id = "${var.project_name}-s3-origin"
        domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
        origin_access_control_id = aws_cloudfront_origin_access_control.frontend-oac.id
    }  
    default_cache_behavior {
      target_origin_id = "${var.project_name}-s3-origin"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET","HEAD"]
      forwarded_values {
        query_string = false
        cookies {
          forward = "none"
        }
      }
    }
    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }
    viewer_certificate {
        acm_certificate_arn = var.acm_certificate_arn
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"

    }
    aliases = ["sarneet.com", "www.sarneet.com"]
    depends_on = [ aws_s3_bucket_public_access_block.frontend ]
}

data "aws_iam_policy_document" "cloudfront_s3_access" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend-cf.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.cloudfront_s3_access.json
}