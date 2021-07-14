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

variable "key-name" {
  default     = "eu-west-3"
  type        = string
  description = "Region of the VPC"
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "instances_per_subnet" {
  description = "Number of EC2 instances in each public subnet"
  type        = number
  default     = 2
}

variable "availability_zones" {
  default     = ["eu-west-3a", "eu-west-3b"]
  type        = list
  description = "List of availability zones"
}
