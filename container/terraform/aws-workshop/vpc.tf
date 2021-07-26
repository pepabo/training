module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "training"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.10.0/24"]

  map_public_ip_on_launch = true

  enable_nat_gateway = true
  single_nat_gateway = true
}

