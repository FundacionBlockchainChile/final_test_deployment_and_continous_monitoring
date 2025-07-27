variable "project_name" {}
variable "vpc_id" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "ecr_repository_url" {}
variable "container_port" {}
variable "container_cpu" {}
variable "container_memory" {}
variable "service_desired_count" {}
variable "aws_region" {
  default = "us-east-1"
} 