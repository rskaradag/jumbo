data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
  name               = "${var.app_name}-iam-role-lambda-trigger"
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "consumer_lambda" {
  filename         = "${path.module}/consumer.zip"
  function_name    = "${var.app_name}-consumer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "consumer.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256


  vpc_config {
    subnet_ids         = [aws_subnet.public[0].id]
    security_group_ids = [aws_security_group.efs-sg.id]
  }

}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/python/consumer.py"
  output_path = "${path.module}/consumer.zip"
}