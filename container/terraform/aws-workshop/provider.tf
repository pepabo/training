provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "Project"     = "training"
      "description" = "managed by terraform"
    }
  }
}
