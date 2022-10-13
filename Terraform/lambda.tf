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
data "aws_iam_policy_document" "AWSlambdaEFSPolicyDoc" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    resources = [
      "*"
    ]
  }
}


resource "aws_iam_role" "lambda_role" {
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
  name               = "${var.app_name}-iam-role-lambda-trigger"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  ]

  inline_policy {
    name   = "efs-policy"
    policy = data.aws_iam_policy_document.AWSlambdaEFSPolicyDoc.json
  }
}

resource "aws_iam_role_policy_attachment" "lambda_api_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.api.arn
}

resource "aws_lambda_function" "consumer" {

  filename         = "${path.module}/consumer.zip"
  function_name    = "${var.app_name}-consumer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "consumer.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256

  tracing_config {
     mode = "Active"
   }

  file_system_config {

    arn = aws_efs_access_point.app.arn

    local_mount_path = "/mnt/efs"
  }

  vpc_config {

    subnet_ids         = [aws_subnet.private[0].id, aws_subnet.private[1].id]
    security_group_ids = [aws_security_group.efs-sg.id]
  }

  depends_on = [aws_efs_mount_target.jumbo_mount]

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.queue.id
      EFS_PATH  = "/mnt/efs"
    }
  }

}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/lambda/consumer.py"
  output_path = "${path.module}/consumer.zip"
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_event" {
  event_source_arn = aws_sqs_queue.queue.arn
  enabled          = true
  function_name    = aws_lambda_function.consumer.arn
  batch_size       = 1
}