variable "aws_region" {
  default = "us-east-1"
}

variable "image" {}

variable "container_port" {
  default = "3000"
}

variable "replicas" {
  default = "2"
}

variable "container_name" {
  default = "app-demo"
}
