output "app_name" {
  value = var.app_name
}
output "queue_URL" {
  value = aws_sqs_queue.queue.id
}
output "test_cURL" {
  value = "curl -X POST -H 'Content-Type: application/json' -d '{\"id\":\"selcuk\", \"file\":\"file\"}' ${aws_api_gateway_deployment.producer.invoke_url}/"
}
output "apigateway_url" {
  value = aws_api_gateway_deployment.producer.invoke_url
}
output "ecr_url" {
  value = aws_ecr_repository.jumbo.repository_url
}
output "lb_url" {
  description = "URL of load balancer"
  value       = "http://${aws_lb.lb.dns_name}/"
}