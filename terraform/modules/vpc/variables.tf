variable "region" {
  type = string
}


variable "env" {
  type = string
}

variable "project_name" {
  type = string
  default = "devopsrt-homelab"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"

}

variable "public_subnets"{
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "private_subnets"{
  type = list(string)
  default = ["10.0.10.0/24","10.0.11.0/24"]
}

variable "azs"{
  type = list(string)
  default = ["ap-south-1a","ap-south-1b"]

}

variable "cluster_name"{
  type = string
  default = "devopsrt-homelab-dev-cluster"
}
