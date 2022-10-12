resource "aws_api_gateway_rest_api" "producer" {
  name        = "${var.app_name}-api"
  description = "POST records to SQS queue"
}

resource "aws_api_gateway_request_validator" "producer" {
  rest_api_id           = aws_api_gateway_rest_api.producer.id
  name                  = "payload-validator"
  validate_request_body = true
}

resource "aws_api_gateway_model" "producer" {
  rest_api_id  = aws_api_gateway_rest_api.producer.id
  name         = "PayloadValidator"
  description  = "validate the json body content conforms to the below spec"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "required": [ "id", "file"],
  "properties": {
    "id": { "type": "string" },
    "file": { "type": "string" }
    }
}
EOF
}

resource "aws_api_gateway_method" "producer" {
  rest_api_id          = aws_api_gateway_rest_api.producer.id
  resource_id          = aws_api_gateway_rest_api.producer.root_resource_id
  api_key_required     = false
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.producer.id

  request_models = {
    "application/json" = "${aws_api_gateway_model.producer.name}"
  }
}

resource "aws_api_gateway_integration" "producer" {
  rest_api_id             = aws_api_gateway_rest_api.producer.id
  resource_id             = aws_api_gateway_rest_api.producer.root_resource_id
  http_method             = "POST"
  type                    = "AWS"
  integration_http_method = "POST"
  passthrough_behavior    = "NEVER"
  credentials             = aws_iam_role.api.arn
  uri                     = "arn:aws:apigateway:${var.aws_region}:sqs:path/${aws_sqs_queue.queue.name}"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}

resource "aws_api_gateway_integration_response" "success" {
  rest_api_id       = aws_api_gateway_rest_api.producer.id
  resource_id       = aws_api_gateway_rest_api.producer.root_resource_id
  http_method       = aws_api_gateway_method.producer.http_method
  status_code       = aws_api_gateway_method_response.success.status_code
  selection_pattern = "^2[0-9][0-9]"

  response_templates = {
    "application/json" = "{\"message\": \"great success!\"}"
  }

  depends_on = ["aws_api_gateway_integration.producer"]
}

resource "aws_api_gateway_method_response" "success" {
  rest_api_id = aws_api_gateway_rest_api.producer.id
  resource_id = aws_api_gateway_rest_api.producer.root_resource_id
  http_method = aws_api_gateway_method.producer.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_deployment" "producer" {
  rest_api_id = aws_api_gateway_rest_api.producer.id
  stage_name  = "main"

  depends_on = [
    "aws_api_gateway_integration.producer"
  ]
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.producer.id
  stage_name  = "main"
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}