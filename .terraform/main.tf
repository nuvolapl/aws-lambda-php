terraform {
  required_version = "~> 0.11"
}

provider "aws" {
  version = "~> 1.60"
  region  = "eu-west-1"
}

provider "archive" {
  version = "~> 1.1"
}

resource "aws_key_pair" "lambda-php" {
  key_name   = "lambda-php"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_s3_bucket" "lambda-php" {
  bucket_prefix = "lambda-php-"
  force_destroy = true
}
