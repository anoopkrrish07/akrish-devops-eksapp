resource "random_id" "id" {
  byte_length = 2
}

module "vpc" {
  # source  = "terraform-aws-modules/vpc/aws"
  # version = "~> 5.5.0"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=f7f84f70ad6db36e4eae0273bf08ed2ffd0a69c4"

  name = "${var.env}-${var.group}-${var.app}-${random_id.id.hex}"
  cidr = var.vpc_cidr

  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  database_subnets     = var.database_subnets
  enable_nat_gateway   = var.vpc_enable_nat_gateway
  single_nat_gateway   = var.vpc_single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    terraform = "true"
    env       = var.env
    group     = var.group
    app       = var.app
  }
}
