terraform {
  backend "s3" {
    bucket = "blin-terraform-state"
    key    = "resume"
    region = "us-east-1"
  }
}
