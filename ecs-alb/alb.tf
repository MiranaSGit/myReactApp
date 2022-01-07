# Getting created VPC and subnets ids for this project.
data "aws_vpc" "vpc-name" {
  filter {
    name   = "tag:Name"
    values = ["Demo-VPC"]
  }
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.vpc-name.id
}

data "aws_subnet" "subnet-ids" {
  count = length(data.aws_subnet_ids.subnets.ids)
  id    = tolist(data.aws_subnet_ids.subnets.ids)[count.index]
}

# Creating ALB and security groups
resource "aws_security_group" "ecs-sg" {
  name   = "ecs-sg"
  vpc_id = data.aws_vpc.vpc-name.id
  tags = {
    "Name" : "demo-ecs-sg"
  }
}

resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "controls access to the LB"
  vpc_id      = data.aws_vpc.vpc-name.id
  tags = {
    "Name" : "demo-lb-sg"
  }
}

resource "aws_security_group_rule" "lb_to_ecs" {
  security_group_id        = aws_security_group.ecs-sg.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb-sg.id
}

resource "aws_security_group_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs-sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_to_lb" {
  security_group_id = aws_security_group.lb-sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

}


resource "aws_security_group_rule" "lb_egress" {
  security_group_id = aws_security_group.lb-sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = data.aws_subnet.subnet-ids.*.id

  enable_deletion_protection = false

  tags = {
    "Name" : "Demo-ALB"
  }
}


resource "aws_alb_target_group" "main-tg" {
  name        = "main-alb-target"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc-name.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main-tg.arn
    type             = "forward"
  }
}

# Create a url for app acces
data "aws_route53_zone" "main" {
  name = "omerfarukdemirozu.net"
}

resource "aws_route53_record" "myapp-url" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "myapp.omerfarukdemirozu.net"
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
