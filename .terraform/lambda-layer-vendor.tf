resource "aws_lambda_layer_version" "vendor" {
  layer_name = "${terraform.workspace}-php-vendor"

  filename         = "${data.archive_file.vendor.output_path}"
  source_code_hash = "${data.archive_file.vendor.output_base64sha256}"
}
