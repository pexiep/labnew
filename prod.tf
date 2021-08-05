#1 - Create VPC

resource "aws_vpc" "prod" {
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"
	
# Required for EKS. Enable/disable DNS support in the VPC.
  enable_dns_support = true

  # Required for EKS. Enable/disable DNS hostnames in the VPC.
  enable_dns_hostnames = true

  tags = {
    Name = "prodVPC"
  }
}

#2- Create Internet Gateway
resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "gw1"
  }
}

#3 - Create Route Table

resource "aws_route_table" "publicprod" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw1.id
  }
	
  tags = {
    Name = "PublicRT1"
  }
}

#4 - Create 9 subnets at 3 seperate AZs (enable auto assign IPv4)

resource "aws_subnet" "publicsubnet1prod" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.2.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnet1prod"
  }
}

resource "aws_subnet" "privatesubnet1prod" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.2.10.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "privatesubnet1prod"
  }
}

resource "aws_subnet" "dbsubnet1prod" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.2.100.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dbsubnet1prod"
  }
}

resource "aws_subnet" "publicsubnet2prod" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.2.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnet2prod"
  }
}

resource "aws_subnet" "privatesubnet2prod" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.2.11.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "privatesubnet2prod"
  }
}

resource "aws_subnet" "dbsubnet2prod" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.2.110.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dbsubnet2prod"
  }
}

resource "aws_subnet" "publicsubnet3prod" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.2.2.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnet3prod"
  }
}

resource "aws_subnet" "privatesubnet3prod" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.2.22.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "privatesubnet3prod"
  }
}

resource "aws_subnet" "dbsubnet3prod" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.2.220.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "dbsubnet3prod"
  }
}

#5 Create association

resource "aws_route_table_association" "a1" { 
  subnet_id      = aws_subnet.publicsubnet1prod.id 
  route_table_id = aws_route_table.publicprod.id 
} 


resource "aws_route_table_association" "b1" { 
  subnet_id      = aws_subnet.publicsubnet2prod.id 
  route_table_id = aws_route_table.publicprod.id 
} 


resource "aws_route_table_association" "c1" { 
  subnet_id      = aws_subnet.publicsubnet3prod.id 
  route_table_id = aws_route_table.publicprod.id 
} 

#6 Create NAT Gateway

resource "aws_eip" "nat1" { 
  vpc      = true 
} 
 
resource "aws_nat_gateway" "ngw1" { 
  allocation_id = aws_eip.nat1.id 
  subnet_id = aws_subnet.publicsubnet2prod.id 
} 
 
