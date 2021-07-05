output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = aws_vpc.main.cidr_block
}

output "subnet_cidr" {
  description = "Subnet CIDR Block"
  value       = aws_subnet.public.cidr_block
}

output "ssh_gateway" {
  description = "Server name"
  value       = aws_instance.ssh_gateway.tags
}

output "protected_server" {
  description = "Server name"
  value       = aws_instance.protected_server.tags
}

output "ssh_gateway_ip" {
  description = "Server IP"
  value       = aws_instance.ssh_gateway.private_ip
}

output "protected_server_ip" {
  description = "Server IP"
  value       = aws_instance.protected_server.private_ip
}

output "igw_id" {
  description = "IGW ID"
  value       = aws_internet_gateway.igw.id
}

output "rtb" {
  description = "Route"
  value       = aws_route_table.public_rt.route
}