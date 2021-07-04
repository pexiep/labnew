output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = aws_vpc.quick_lab.cidr_block
}

output "subnet_cidr" {
  description = "Subnet CIDR Block"
  value       = aws_subnet.quick_lab.cidr_block
}

output "server_id" {
  description = "Server name"
  value       = ["${aws_instance.quick_lab.*.tags}"]
}

output "server_ip" {
  description = "Server IP"
  value       = ["${aws_instance.quick_lab.*.private_ip}"]
}