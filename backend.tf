terraform {
  backend "s3" {
    bucket       = "shamil-terraform-state-2026-148908330969"
    key          = "cloud-native-task-manager/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
