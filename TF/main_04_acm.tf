##########################
### AWS ACM certificate
### Due to the CloudFront distribution limitation, the certificate must be in the us-east-1 region
##########################

resource "aws_acm_certificate" "cert" {
  provider = aws.use1
  domain_name       = local.config.global.domain_name
  subject_alternative_names = ["www.${local.config.global.domain_name}"]
  validation_method = "DNS"

  tags = merge(
    local.common_tags,
    {
      "Name"           = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "acm"])))
      "Category"       = "acm"
      "Criticality"    = "true"
      "Location"       = "${local.config.global.region_id}"
      "Environment"    = "PROD"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.use1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_route53_record : record.fqdn]
  depends_on = [aws_route53_record.acm_route53_record]
}

