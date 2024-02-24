resource "aws_ecr_repository" "ecr" {
  name                 = "my-ecr-repo"
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    terraform = "true"
    env       = var.env
    group     = var.group
    app       = var.app
  }
}
