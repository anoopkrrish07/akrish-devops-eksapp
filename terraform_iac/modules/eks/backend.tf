# terraform {
#   backend "s3" {
#     profile        = "" # if using role
#     bucket         = ""
#     key            = "repo-name/eu-west-2/vpc/dev/terraform.tfstate"
#     region         = "eu-west-2"
#     dynamodb_table = "repo-name-terraform-state-locking"
#     encrypt        = true
#   }
# }
