variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.2.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "managed_policies" {
  default = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"]
}

variable "key_name" {
  default = "ofd"
}

variable "app-name" {
  default = "react-demo"
}


