data "archive_file" "aws-lambda-function-php" {
  type        = "zip"
  source_dir  = "../src"
  output_path = "../var/functions/src.zip"
}

resource "aws_lambda_function" "php" {
  function_name = "php"
  filename      = "${data.archive_file.aws-lambda-function-php.output_path}"

  role = "${aws_iam_role.lambda-php.arn}"

  handler = "App\\Handler\\EntryPointHandler"

  source_code_hash = "${data.archive_file.aws-lambda-function-php.output_base64sha256}"
  runtime          = "provided"

  layers = [
    "${aws_lambda_layer_version.runtime-php.arn}:${aws_lambda_layer_version.runtime-php.version}",
    "${aws_lambda_layer_version.vendor-php.arn}:${aws_lambda_layer_version.vendor-php.version}",
  ]

  vpc_config {
    security_group_ids = ["${aws_security_group.lambda-php.id}"]
    subnet_ids         = ["${module.vpc.public_subnets}"]
  }
}

resource "aws_lambda_permission" "lambda-php" {
  statement_id  = "load-balancer"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.php.arn}"
  principal     = "elasticloadbalancing.amazonaws.com"

  source_arn = "${aws_alb_target_group.lambda-php.arn}"
}
