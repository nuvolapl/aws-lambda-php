resource "aws_acm_certificate" "lambda-php" {
  domain_name               = "${var.domain}"
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "lambda-php" {
  certificate_arn = "${aws_acm_certificate.lambda-php.arn}"
}

resource "aws_security_group" "world" {
  name_prefix = "lambda-php-world-"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "lambda-php" {
  name            = "lambda-php"
  security_groups = ["${aws_security_group.world.id}"]
  subnets         = ["${module.vpc.public_subnets}"]

  access_logs {
    enabled = true
    bucket  = "${aws_s3_bucket.lambda-php.bucket}"
    prefix  = "lambda-php-world-logs"
  }
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb-proxy" {
  bucket = "${aws_s3_bucket.lambda-php.id}"

  policy = <<JSON
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowToPutLoadBalancerLogsToS3Bucket",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.lambda-php.arn}/*/*"
        }
    ]
}
JSON
}

resource "aws_alb_target_group" "lambda-php" {
  name        = "lambda-php"
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "lambda-php" {
  target_group_arn = "${aws_alb_target_group.lambda-php.arn}"
  target_id        = "${aws_lambda_function.php.arn}"
  depends_on       = ["aws_lambda_permission.lambda-php"]
}

resource "aws_alb_listener" "world" {
  load_balancer_arn = "${aws_alb.lambda-php.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.lambda-php.arn}"
  depends_on        = ["aws_alb_target_group.lambda-php"]

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.lambda-php.arn}"
  }
}

resource "aws_security_group" "lambda-php" {
  name_prefix = "lambda-php"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = ["${aws_alb.lambda-php.security_groups}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
