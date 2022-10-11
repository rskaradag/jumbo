output "queue_URL" {
  value = aws_sqs_queue.queue.id
}
output "test_cURL" {
  value = "curl -X POST -H 'Content-Type: application/json' -d '{\"id\":\"selcuk\", \"file\":\"file\"}' ${aws_api_gateway_deployment.producer.invoke_url}/"
}
output "lb_url" {
  description = "URL of load balancer"
  value       = "http://${aws_lb.lb.dns_name}/"
}