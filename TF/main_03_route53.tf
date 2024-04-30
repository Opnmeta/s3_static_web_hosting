##########################
### AWS Route53
##########################

# get a Route53 zone
data "aws_route53_zone" "route53_zone" {
  provider = aws.main
  name     = local.config.global.domain_name
  private_zone = false
}

# Create Route53 records for the ACM certificate validation
resource "aws_route53_record" "acm_route53_record" {
    provider = aws.main
    for_each = {
      for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
      }
    }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}
# Create Route53 A records for the CloudFront distribution for domain "example.com"
resource "aws_route53_record" "route53_root_a_record" {
  provider = aws.main
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = local.config.global.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

# Create Route53 CNAME records for the CloudFront distribution for domain "www.example.com"
resource "aws_route53_record" "route53_www_cname_record" {
  provider = aws.main
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "www.${local.config.global.domain_name}"
  type    = "CNAME"
  ttl     = 3600
  records = [aws_cloudfront_distribution.s3_distribution.domain_name]
}

