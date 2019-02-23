resource "aws_iam_role" "lambda-php" {
  name = "aws-lambda-php"

  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
JSON
}

resource "aws_iam_policy" "aws-lambda-php-cloudwatch" {
  name = "${aws_iam_role.lambda-php.name}-cloudwatch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws-lambda-php-cloudwatch" {
  role       = "${aws_iam_role.lambda-php.name}"
  policy_arn = "${aws_iam_policy.aws-lambda-php-cloudwatch.arn}"
}

resource "aws_iam_policy" "aws-lambda-php-ec2" {
  name = "${aws_iam_role.lambda-php.name}-ec2"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DetachNetworkInterface",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws-lambda-php-ec2" {
  role       = "${aws_iam_role.lambda-php.name}"
  policy_arn = "${aws_iam_policy.aws-lambda-php-ec2.arn}"
}
