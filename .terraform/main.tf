terraform {
  required_version = "~> 0.11"

  backend "s3" {
    region = "eu-west-1"
    bucket = "tfstate.nuvola.pl"
    key    = "aws-lambda-php/tfstate.json"
  }
}
