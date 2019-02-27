# variables
variable "ssh-public-key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "vpc-public-subnets" {
  type    = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

# archives
data "archive_file" "runtime" {
  type        = "zip"
  source_dir  = "../runtime"
  output_path = "../var/runtime.zip"
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "../src"
  output_path = "../var/src.zip"
}

data "archive_file" "vendor" {
  type        = "zip"
  source_dir  = "../vendor"
  output_path = "../var/vendor.zip"
}

# vpc
data "aws_availability_zones" "this" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "lambda-php"

  cidr           = "${var.vpc-cidr}"
  azs            = "${slice(data.aws_availability_zones.this.names, 0, length(var.vpc-public-subnets))}"
  public_subnets = "${var.vpc-public-subnets}"

  enable_dns_hostnames = true
}

# security
resource "aws_iam_role" "this" {
  name = "lambda-php"

  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
JSON
}

resource "aws_iam_policy" "this" {
  name = "lambda-php"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = "${aws_iam_role.this.name}"
  policy_arn = "${aws_iam_policy.this.arn}"
}
