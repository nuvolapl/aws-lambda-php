resource "aws_lambda_layer_version" "runtime" {
  layer_name = "${terraform.workspace}-php-runtime"

  filename         = "${data.archive_file.runtime.output_path}"
  source_code_hash = "${data.archive_file.runtime.output_base64sha256}"
}
