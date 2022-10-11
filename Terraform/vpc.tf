resource "aws_vpc" "jumbo_vpc" {
  cidr_block           = var.vpc_subnet
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}
resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.jumbo_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.public[0].id, aws_subnet.public[1].id]
  ip_address_type     = "ipv4"
  private_dns_enabled = true

  tags = {
    Name = "${var.app_name}-sqs"
  }

  security_group_ids = [
    aws_security_group.efs-sg.id,
  ]

}