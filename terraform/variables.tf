variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_profile" {
  type = string
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the private SSH key"
  type        = string
}
