variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_profile" {
  type = string
}

variable "runc_version" {
  type    = string
  default = "1.3.0"
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the private SSH key"
  type        = string
}

variable "script_paths" {
  description = "Local paths to scripts to copy"
  type        = list(string)
  default     = []
}
