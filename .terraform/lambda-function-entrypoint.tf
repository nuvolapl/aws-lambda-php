resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.entrypoint.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_function" "entrypoint" {
  function_name = "${terraform.workspace}-php-entrypoint"
  filename      = "${data.archive_file.src.output_path}"

  role = "${aws_iam_role.this.arn}"

  handler = "App\\Handler\\EntrypointHandler"

  source_code_hash = "${data.archive_file.src.output_base64sha256}"
  runtime          = "provided"

  layers = [
    "${aws_lambda_layer_version.runtime.arn}:${aws_lambda_layer_version.runtime.version}",
    "${aws_lambda_layer_version.vendor.arn}:${aws_lambda_layer_version.vendor.version}",
  ]

  vpc_config {
    security_group_ids = ["${aws_security_group.entrypoint.id}"]
    subnet_ids         = ["${module.vpc.public_subnets}"]
  }
}

resource "aws_api_gateway_rest_api" "this" {
  name = "${aws_lambda_function.entrypoint.function_name}"
}

resource "aws_api_gateway_resource" "entrypoint" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  parent_id   = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "entrypoint" {
  rest_api_id   = "${aws_api_gateway_resource.entrypoint.rest_api_id}"
  resource_id   = "${aws_api_gateway_resource.entrypoint.id}"
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters {
    method.request.path.proxy = true
  }
}

resource "aws_api_gateway_integration" "entrypoint" {
  rest_api_id = "${aws_api_gateway_method.entrypoint.rest_api_id}"
  resource_id = "${aws_api_gateway_method.entrypoint.resource_id}"
  http_method = "${aws_api_gateway_method.entrypoint.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.entrypoint.invoke_arn}"

  content_handling = "CONVERT_TO_TEXT"

  cache_key_parameters = [
    "method.request.path.proxy",
  ]
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    "aws_api_gateway_integration.entrypoint",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  stage_name  = "${terraform.workspace}"
}

resource "aws_lambda_permission" "entrypoint" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.entrypoint.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.this.execution_arn}/*/*"
}

resource "aws_security_group" "entrypoint" {
  name_prefix = "lambda-php-entrypoint-"

  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "lambda-php-entrypoint" {
  value = "${aws_api_gateway_deployment.this.invoke_url}"
}
