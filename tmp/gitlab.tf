data "aws_ami" "ubuntu-ami" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "ecr-access-role" {
  name = "demo-ecr-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "AWS Role for Gitlab"
  }
}


resource "aws_iam_role_policy_attachment" "ecr-role-policy-attachment" {
  count      = length(var.managed_policies)
  role       = aws_iam_role.ecr-access-role.name
  policy_arn = element(var.managed_policies, count.index)
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "gitlab-profile"
  role = aws_iam_role.ecr-access-role.name
}

resource "aws_instance" "gitlab" {
  ami                         = data.aws_ami.ubuntu-ami.id
  instance_type               = "t3.medium"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.sec-gr.id]
  subnet_id                   = aws_subnet.demo_subnets[0].id
  user_data                   = file("gitlab-userdata.sh")
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile.name
  tags = {
    Name = "GitLab-Server"
  }
}

# resource "aws_instance" "gitlab-runner" {
#   ami                         = data.aws_ami.ubuntu-ami.id
#   instance_type               = "t3.medium"
#   key_name                    = var.key_name
#   vpc_security_group_ids      = [aws_security_group.sec-gr.id]
#   subnet_id                   = aws_subnet.demo_subnets[0].id
#   user_data                   = file("gitlab-userdata.sh")
#   associate_public_ip_address = true
#   iam_instance_profile        = aws_iam_instance_profile.ec2-profile.name
#   tags = {
#     Name = "GitLab-Runner"
#   }
# }

resource "aws_security_group" "sec-gr" {
  name   = "gitlab-secgr"
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    Name = "gitlab-secgr-secgr"
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a url for gitlab acces
data "aws_route53_zone" "main" {
  name = "omerfarukdemirozu.net"
}

resource "aws_route53_record" "gitlab-url" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "gitlab.omerfarukdemirozu.net"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.gitlab.public_ip]
}
