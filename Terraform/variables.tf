variable "aws_region" {
  default = "eu-central-1"
}
variable "access_key_id" {

}
variable "secret_access_key" {

}
variable "aws_account_id" {
  default = "600210043783"
}
variable "app_name" {
  default = "myjumbo"
}
variable "app_environment" {
  default = "development"
}
variable "availability_zones" {
  default     = ["eu-central-1a", "eu-central-1b"]
  description = "Availability Zones"
}
variable "vpc_subnet" {
  default     = "10.10.0.0/16"
  description = "VPC Subnet"
}
variable "public_subnets" {
  default     = ["10.10.1.0/24", "10.10.3.0/24"]
  description = "Public Subnet Blocks"
}
variable "private_subnets" {
  default     = ["10.10.2.0/24", "10.10.4.0/24"]
  description = "Private Subnet Blocks"
}
variable key_name {
default     = "LL-TEST"
type = string
}