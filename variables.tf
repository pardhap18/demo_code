#---------variables---------

variable "aws_region" {}

variable "aws_profile" {}

data "aws_availability_zones" "available" {}

variable "vpc_cidr" {}

variable "cidrs" {
  type = "map"
}

variable "domain_name" {}

variable "jenk_instance_type" {}

variable "jenk_ami" {}

variable "public_key_path" {}

variable "key_name" {}
