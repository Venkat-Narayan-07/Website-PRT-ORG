provider "aws" {
  secret_key= ""
  access_key= ""
  region = "eu-north-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "custom" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "custom-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.custom.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_web_traffic" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}

resource "aws_instance" "t3_small" {
  ami           = "ami-07a0715df72e58928"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.custom.id
  key_name      = "venkat"

  vpc_security_group_ids = [aws_security_group.allow_web_traffic.id]

  associate_public_ip_address = true

  tags = {
    Name = "t3-small-instance"
  }
}

resource "aws_instance" "t3_micro" {
  count         = 2
  ami           = "ami-07a0715df72e58928"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.custom.id
  key_name      = "venkat"

  vpc_security_group_ids = [aws_security_group.allow_web_traffic.id]

  associate_public_ip_address = true

  tags = {
    Name = "t3-micro-instance-${count.index}"
  }
}

output "t3_small_instance_public_ip" {
  value = aws_instance.t3_small.public_ip
}

output "t3_micro_instance_public_ips" {
  value = [for instance in aws_instance.t3_micro : instance.public_ip]
}
