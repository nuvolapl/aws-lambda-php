provider "cloudflare" {
  version = "~> 0.1"
}

resource "cloudflare_record" "certificate-validation" {
  domain = "${aws_acm_certificate.lambda-php.domain_validation_options.0.domain_name}"
  type   = "${aws_acm_certificate.lambda-php.domain_validation_options.0.resource_record_type}"
  name   = "${aws_acm_certificate.lambda-php.domain_validation_options.0.resource_record_name}"
  value  = "${substr(aws_acm_certificate.lambda-php.domain_validation_options.0.resource_record_value, 0, length(aws_acm_certificate.lambda-php.domain_validation_options.0.resource_record_value)-1)}"
}

resource "cloudflare_record" "domain" {
  domain  = "${aws_acm_certificate.lambda-php.domain_name}"
  type    = "CNAME"
  name    = "lambda.${aws_acm_certificate.lambda-php.domain_name}"
  value   = "${aws_alb.lambda-php.dns_name}"
  proxied = false
}
