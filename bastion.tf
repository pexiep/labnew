#1 - Create VPC

resource "aws_vpc" "bastion" {
  cidr_block       = "10.3.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "bastionvpc"
  }
}

#2- Create Internet Gateway
resource "aws_internet_gateway" "gw2" {
  vpc_id = aws_vpc.bastion.id

  tags = {
    Name = "gw"
  }
}

#3 - Create Route Table

resource "aws_route_table" "public2" {
  vpc_id = aws_vpc.bastion.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw2.id
  }
	
  tags = {
    Name = "PublicRT2"
  }
}

#4 - Create 9 subnets at 3 seperate AZs (enable auto assign IPv4)

resource "aws_subnet" "publicbastion1" {
  vpc_id     = aws_vpc.bastion.id
  cidr_block = "10.3.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "bastionpublic1"
  }
}

resource "aws_subnet" "privatebastion1" {
  vpc_id     = aws_vpc.bastion.id
  cidr_block = "10.3.10.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "bastionprivate1"
  }
}

resource "aws_subnet" "publicbastion2" {
  vpc_id     = aws_vpc.bastion.id
  cidr_block = "10.3.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "bastionpublic2"
  }
}

resource "aws_subnet" "privatebastion2" {
  vpc_id     = aws_vpc.bastion.id
  cidr_block = "10.3.11.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "bastionprivate2"
  }
}

resource "aws_subnet" "publicbastion3" {
  vpc_id     = aws_vpc.bastion.id
  cidr_block = "10.3.2.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "bastionpublic3"
  }
}

resource "aws_subnet" "privatebastion3" {
  vpc_id     = aws_vpc.bastion.id
  cidr_block = "10.3.22.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "bastionprivate3"
  }
}

#5 Create NAT Gateway

resource "aws_nat_gateway" "example2" {
  subnet_id     = "10.3.2.0/24"

  tags = {
    Name = "gw NAT"
  }
}
