output "test_cURL" {
  value = "curl -X POST -H 'Content-Type: application/json' -d '{\"person\":\"selcuk\", \"docs\":[{\"key.txt\":61}]}' ${aws_api_gateway_deployment.api.invoke_url}/"
}