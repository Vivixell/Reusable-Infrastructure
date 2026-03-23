terraform {
  backend "s3" {
    bucket       = "ovr-statefile-bucket-unique-name"
    key          = "environments/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}