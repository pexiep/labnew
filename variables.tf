variable "access_key" {
     description = "Access key to AWS console"
}

variable "secret_key" {
     description = "Secret key to AWS console"
}

variable "key_name" {
  type        = string
  description = "Key Pairs."
  sensitive   = true
}
