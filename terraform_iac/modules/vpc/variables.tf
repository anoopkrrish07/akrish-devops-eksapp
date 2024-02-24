#-----------------------------------------------------------------------------------------------------------
# Global variables
#-----------------------------------------------------------------------------------------------------------

variable "env" {
  type    = string
  default = "dev"
}

variable "group" {
  type    = string
  default = "devops"
}

variable "app" {
  type    = string
  default = "pytest"
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

#-----------------------------------------------------------------------------------------------------------
# VPC Vars
#-----------------------------------------------------------------------------------------------------------

variable "azs" {
  type    = list(any)
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "private_subnets" {
  type    = list(any)
  default = ["10.10.32.0/19", "10.10.64.0/19", "10.10.96.0/19"]
}

variable "public_subnets" {
  type    = list(any)
  default = ["10.10.160.0/21", "10.10.168.0/21", "10.10.176.0/21"]
}

variable "database_subnets" {
  type    = list(any)
  default = ["10.10.184.192/26", "10.10.184.64/26", "10.10.184.128/26"]
}

variable "vpc_enable_nat_gateway" {
  default = true
}

variable "vpc_single_nat_gateway" {
  default = true
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}
