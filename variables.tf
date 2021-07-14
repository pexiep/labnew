variable "access_key" {
     description = "Access key to AWS console"
   
}
variable "secret_key" {
     description = "Secret key to AWS console"
     
}

variable "region" {
  default     = "eu-west-3"
  type        = string
  description = "Region of the VPC"
}

variable "key_name" {
  type        = string
  description = "Key Pairs."
  sensitive   = true
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "availability_zones" {
  type        = list
  description = "List of availability zones"
}
