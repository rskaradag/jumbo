resource "aws_vpc" "jumbo_vpc" {
  cidr_block           = var.vpc_subnet
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}