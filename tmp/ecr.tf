resource "aws_ecr_repository" "main" {
  name                 = "${var.app-name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}