variable "project_name" { type = string }
variable "env" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) } # For ALB later
# variable "cluster_security_group_id" { type = string } # From VPC module
variable "instance_types" {
  type = list(string)
  default = ["t2.micro"]
}
