resource "aws_ecr_repository" "jumbo" {
  name = "${var.app_name}repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  provisioner "local-exec" {
    #command = "./Docker/deploy-image.sh ${aws_ecr_repository.app_ecr.repository_url} ${var.app_name}"
    command = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.jumbo.repository_url} && docker build -t ${var.app_name} -f Docker/Dockerfile.webserver Docker/. && docker tag ${var.app_name}:latest ${aws_ecr_repository.jumbo.repository_url}:latest && docker push ${aws_ecr_repository.jumbo.repository_url}:latest"
  }
}

