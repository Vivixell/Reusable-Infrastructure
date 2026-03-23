terraform {
  backend "s3" {
    bucket       = "ovr-statefile-bucket-unique-name"
    key          = "environments/prod/terraform.tfstate" # Strict Prod Path
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}