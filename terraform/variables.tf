variable "aws_region" {
  default = "eu-central-1"
}
variable "app_name" {
  default = "myjumbo"
}
variable "app_environment" {
  default = "development"
}
variable "availability_zones" {
  default = ["eu-central-1a"]
}
variable "vpc_subnet" {
  default = "10.10.0.0/16"
}
variable "public_subnets" {
  default = ["10.10.1.0/24"]
}
variable "private_subnets" {
  default = ["10.10.2.0/24"]
}