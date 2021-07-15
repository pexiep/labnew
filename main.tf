terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

#1 - Create VPC

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC"
  }
}

#2- Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "gw"
  }
}

#3 - Create Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
	
  tags = {
    Name = "PublicRT"
  }
}

#4 - Create 2 subnets at 2 seperate AZs (enable auto assign IPv4)

resource "aws_subnet" "main1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "main2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet2"
  }
}

#5 - Assign Route Table into subnets  (Edit route table association)

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.main2.id
  route_table_id = aws_route_table.public.id
}

#6 - Create Security Groups

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
         from_port = 80
         to_port = 80
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
    }
     ingress {
         from_port = 443
         to_port = 443
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
    }
	ingress {
         from_port = 22
         to_port = 22
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "allow_web"
  }
}

#6.1 Create Network interface NIC and EIP

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.main1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
}

#7 - Create EC2

resource "aws_instance" "web-server-instance" {
    count = 4
    ami = "ami-09e67e426f25ce0d7"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = var.key_name

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id
    }

    user_data = <<-EOF
                #!bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo Hello from THE ANH > /var/www/html/index.html'
                EOF
    tags = {
   	 Name = "Server ${count.index}"
    }
}

#9 - Create Elastic LoadBalance



