variable "env" {
  description = "The environment name (e.g., dev, prod)"
  type = string
  default = "dev"
}

variable "region" {
  type = string
  default = "ap-south-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "devopsrt-homelab"
}
