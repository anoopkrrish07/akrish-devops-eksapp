## Global Parameters
env                    = "dev"
group                  = "devops"
app                    = "sample"
aws_region             = "eu-west-2" #"REGION"

## VPC Parameters
azs                    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"] #["REGIONa", "REGIONb", "REGIONc"]
vpc_cidr               = "10.20.0.0/16"
private_subnets        = ["10.20.32.0/19", "10.20.64.0/19", "10.20.96.0/19"]
public_subnets         = ["10.20.160.0/21", "10.20.168.0/21", "10.20.176.0/21"]
database_subnets       = ["10.20.184.192/26", "10.20.184.64/26", "10.20.184.128/26"]
vpc_enable_nat_gateway = true
vpc_single_nat_gateway = true
