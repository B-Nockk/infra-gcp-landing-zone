# terraform/environments/local/backend.tf
terraform {
  backend "local" {
    # This tells Terraform to store the state locally in this directory
    path = "terraform.tfstate"
  }
}
