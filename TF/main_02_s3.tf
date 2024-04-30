##########################
### AWS S3 bucket for website static files
##########################

# AWS S3 bucket for static website hosting
resource "aws_s3_bucket" "s3_web_bucket" {
  provider = aws.main
  bucket = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "web","s3"])))

  lifecycle {
    ignore_changes = [
      policy
    ]
  }


  tags = merge(
    local.common_tags,
    {
      "Name"           = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "web","s3"])))
      "Category"       = "s3"
      "Criticality"    = "true"
      "Location"       = "${local.config.global.region_id}"
    }
  )

}

# Bucket policy for allowing access from CloudFront
resource "aws_s3_bucket_policy" "web_bucket_policy" {
  provider = aws.main
  bucket = aws_s3_bucket.s3_web_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront_s3_policy.json
  depends_on = [data.aws_iam_policy_document.allow_access_from_cloudfront_s3_policy]
}

data "aws_iam_policy_document" "allow_access_from_cloudfront_s3_policy" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_web_bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["${aws_cloudfront_distribution.s3_distribution.arn}"]
    }
  }
}

##########################
### AWS S3 bucket for CloudFront access logs
##########################

# AWS S3 bucket or cloudfront access log 
resource "aws_s3_bucket" "s3_logging_bucket" {
  provider = aws.main
  bucket = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "logging","s3"])))


  tags = merge(
    local.common_tags,
    {
      "Name"           = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "logging","s3"])))
      "Category"       = "s3"
      "Criticality"    = "true"
      "Location"       = "${local.config.global.region_id}"
    }
  )

}

# Bucket ownership controls for allowing CloudFront put logs to s3 bucket
resource "aws_s3_bucket_ownership_controls" "logging_bucket_ownership_ctrl" {
  provider = aws.main
  bucket = aws_s3_bucket.s3_logging_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Bucket lifecycle configuration for access log archive
resource "aws_s3_bucket_lifecycle_configuration" "access_log_archive" {
  provider = aws.main
  bucket = aws_s3_bucket.s3_logging_bucket.id

  rule {
    id = "Cloudfront_Access_Log_Archive"
    
    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload{
      days_after_initiation = 7
    }

    filter {}

    # ... other transition/expiration actions ...

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}






