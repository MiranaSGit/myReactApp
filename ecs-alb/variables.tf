variable "aws_region" {
  default = "us-east-1"
}

variable "image" {
  default = "360800251837.dkr.ecr.us-east-1.amazonaws.com/demo-app:latest"
}

variable "container_port" {
  default = "3000"
}

variable "replicas" {
  default = "2"
}

variable "container_name" {
  default = "app-demo"
}
