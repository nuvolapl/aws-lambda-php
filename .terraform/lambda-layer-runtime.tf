data "archive_file" "aws-lambda-layer-runtime" {
  type        = "zip"
  source_dir  = "../runtime"
  output_path = "../var/layers/runtime.zip"
}

resource "aws_lambda_layer_version" "runtime-php" {
  layer_name       = "php-runtime"
  filename         = "${data.archive_file.aws-lambda-layer-runtime.output_path}"
  source_code_hash = "${data.archive_file.aws-lambda-layer-runtime.output_base64sha256}"
}
