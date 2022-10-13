resource "aws_sqs_queue" "queue" {
  name                      = "${var.app_name}-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  kms_master_key_id                 = aws_kms_key.key.id
  kms_data_key_reuse_period_seconds = 300
}

resource "aws_kms_key" "key" {
  description = "SQS Key"
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "600210043783"
      },
      "Action": [
        "SQS:*"
      ],
      "Resource": "arn:aws:sqs:eu-central-1:600210043783:myjumbo-queue"
    },
    {
      "Sid": "__sender_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::600210043783:role/myjumbo-iam-role-lambda-trigger"
        ]
      },
      "Action": [
        "SQS:SendMessage"
      ],
      "Resource": "arn:aws:sqs:eu-central-1:600210043783:myjumbo-queue"
    },
    {
      "Sid": "__receiver_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::600210043783:role/myjumbo-iam-role-lambda-trigger"
        ]
      },
      "Action": [
        "SQS:ChangeMessageVisibility",
        "SQS:DeleteMessage",
        "SQS:ReceiveMessage"
      ],
      "Resource": "arn:aws:sqs:eu-central-1:600210043783:myjumbo-queue"
    }
  ]
}
POLICY
}