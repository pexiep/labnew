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

resource "aws_vpc" "nonprod" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "nonprodVPC"
  }
}

#2- Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.nonprod.id

  tags = {
    Name = "gw"
  }
}

#3 - Create Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nonprod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
	
  tags = {
    Name = "PublicRT"
  }
}

#4 - Create 9 subnets at 3 seperate AZs (enable auto assign IPv4)

resource "aws_subnet" "publicsubnet1" {
  vpc_id     = aws_vpc.nonprod.id
  cidr_block = "10.1.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "privatesubnet1" {
  vpc_id     = aws_vpc.nonprod.id
  cidr_block = "10.1.10.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "dbsubnet1" {
  vpc_id     = aws_vpc.nonprod.id
  cidr_block = "10.1.100.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "DBSubnet1"
  }
}

resource "aws_subnet" "publicsubnet2" {
  vpc_id     = aws_vpc.nonprod.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_subnet" "privatesubnet2" {
  vpc_id     = aws_vpc.nonprod.id
  cidr_block = "10.1.11.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "privatesubnet2"
  }
}

resource "aws_subnet" "dbsubnet2" {
  vpc_id     = aws_vpc.nonprod.id
  cidr_block = "10.1.110.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dbsubnet2"
  }
}

resource "aws_subnet" "publicsubnet3" {
  vpc_id     = aws_vpc.nonprod.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet3"
  }
}

resource "aws_subnet" "privatesubnet3" {
  vpc_id     = aws_vpc.nonprod.id
  cidr_block = "10.1.22.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "privatesubnet3"
  }
}

resource "aws_subnet" "dbsubnet3" {
  vpc_id     = aws_vpc.nonprod.id
  cidr_block = "10.1.220.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "dbsubnet3"
  }
}

#5 Create association

resource "aws_route_table_association" "a" { 
  subnet_id      = aws_subnet.publicsubnet1.id 
  route_table_id = aws_route_table.public.id 
} 


resource "aws_route_table_association" "b" { 
  subnet_id      = aws_subnet.publicsubnet2.id 
  route_table_id = aws_route_table.public.id 
} 


resource "aws_route_table_association" "c" { 
  subnet_id      = aws_subnet.publicsubnet3.id 
  route_table_id = aws_route_table.public.id 
} 

#6 Create NAT Gateway

resource "aws_eip" "nat" { 
  vpc      = true 
} 
 
resource "aws_nat_gateway" "ngw" { 
  allocation_id = aws_eip.nat.id 
  subnet_id = aws_subnet.publicsubnet2.id 
} 
