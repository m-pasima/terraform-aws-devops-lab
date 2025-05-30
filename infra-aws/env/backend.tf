terraform {
  backend "s3" {
    bucket         = "demo-basics"
    key            = "dev/terraform.tfstate"    # You can make this dynamic per env if needed eg dev/prod/staging
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
