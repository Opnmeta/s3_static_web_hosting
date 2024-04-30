##########################
### AWS CloudFront
##########################

# Create an origin access control for the S3 bucket
resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  provider = aws.main
  name                              = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "cloudfront","oac"])))
  description                       = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "cloudfront","oac","Policy"])))
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Create a CloudFront distribution with access logs
resource "aws_cloudfront_distribution" "s3_distribution" {
  provider = aws.main
  origin {
    domain_name              = aws_s3_bucket.s3_web_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
    origin_id                = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "cloudfront","origin","id"])))
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "cloudfront","distribution"])))
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.s3_logging_bucket.bucket_domain_name
    prefix          = "cloudfront_access_logs"
  }


  aliases = ["${local.config.global.domain_name}","www.${local.config.global.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "cloudfront","origin","id"])))

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }


  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = merge(
    local.common_tags,
    {
      "Name"           = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "cloudfront","distribution"])))
      "Category"       = "cloudfront"
      "Criticality"    = "true"
      "Location"       = "${local.config.global.region_id}"
      "Environment"    = "PROD"
    }
  )

}
