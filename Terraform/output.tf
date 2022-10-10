output "queue_URL" {
  value = aws_sqs_queue.queue.id
}
output "test_cURL" {
  value = "curl -X POST -H 'Content-Type: application/json' -d '{\"id\":\"selcuk\", \"file\":\"file\"}' ${aws_api_gateway_deployment.producer.invoke_url}/"
}
output "master_ssh_command" {
  value       = "ssh ubuntu@${aws_instance.master.public_ip} -i ${local_file.private_key.filename}"
  description = "Master SSH Command"
}
output "lb_url" {
  description = "URL of load balancer"
  value       = "http://${aws_lb.lb.dns_name}/"
}
output "key_name" {
  value = aws_key_pair.master.key_name
}