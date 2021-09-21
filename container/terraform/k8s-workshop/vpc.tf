module "k8s-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "training-k8s"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.0.0/19", "10.0.32.0/19"]
  private_subnets = ["10.0.64.0/24", "10.0.96.0/24"]

  map_public_ip_on_launch = false
  enable_nat_gateway      = true
}
