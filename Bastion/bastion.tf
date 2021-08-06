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
    Name = "gw2"
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

#5 Create association

resource "aws_route_table_association" "a2" { 
  subnet_id      = aws_subnet.publicbastion1.id 
  route_table_id = aws_route_table.public2.id 
} 


resource "aws_route_table_association" "b2" { 
  subnet_id      = aws_subnet.publicbastion2.id 
  route_table_id = aws_route_table.public2.id 
} 


resource "aws_route_table_association" "c2" { 
  subnet_id      = aws_subnet.publicbastion3.id 
  route_table_id = aws_route_table.public2.id 
} 

#6 Create NAT Gateway

resource "aws_eip" "nat2" { 
  vpc      = true 
} 
 
resource "aws_nat_gateway" "ngw2" { 
  allocation_id = aws_eip.nat2.id 
  subnet_id = aws_subnet.publicbastion3.id 
} 

#7 - Create Security Groups

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main.id

	ingress {
         from_port = 22
         to_port = 22
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
    }
  egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "allow_web"
  }
}

#7.1 Create Network interface NIC and EIP security group allow port ssh 22, and nat gateway with ingress and outgress based on that one

resource "aws_network_interface" "bastion1-nic" {
  subnet_id       = aws_subnet.bastion.id
  private_ips     = ["10.3.10.5"]
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.bastion1-nic.id
  associate_with_private_ip = "10.3.10.5"
}

#8 - Create EC2 for 3 bastion host create launch template and auto scaling after that



resource "aws_instance" "web-server-instance" {
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
   	 Name = "webserver"
    }
}
