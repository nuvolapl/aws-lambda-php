data "archive_file" "aws-lambda-layer-vendor" {
  type        = "zip"
  source_dir  = "../vendor"
  output_path = "../var/layers/vendor.zip"
}

resource "aws_lambda_layer_version" "vendor-php" {
  layer_name       = "php-vendor"
  filename         = "${data.archive_file.aws-lambda-layer-vendor.output_path}"
  source_code_hash = "${data.archive_file.aws-lambda-layer-vendor.output_base64sha256}"
}
