resource "aws_vpc" "demo_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Demo-VPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "demo_subnets" {
  count                = var.az_count
  vpc_id               = aws_vpc.demo_vpc.id
  cidr_block           = cidrsubnet(aws_vpc.demo_vpc.cidr_block, 2, count.index)
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index%2]

  tags = {
      "Name" : "demo-subnet-${count.index}"
  }
}


resource "aws_route_table" "lbroute" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "webroute-table"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "igw-demo"
  }
}

resource "aws_route" "internet_access_web" {
  route_table_id         = aws_route_table.lbroute.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_web_route_table_association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.demo_subnets.*.id, count.index)
  route_table_id = aws_route_table.lbroute.id
}