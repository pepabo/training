data "aws_eks_cluster" "training-cluster" {
  name = module.training-cluster.cluster_id
}

data "aws_eks_cluster_auth" "training-cluster" {
  name = module.training-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.training-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.training-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.training-cluster.token
}

module "training-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "training-cluster"
  cluster_version = "1.21"
  subnets         = module.k8s-vpc.private_subnets
  vpc_id          = module.k8s-vpc.vpc_id

  node_groups = [
    {
      max_capacity     = 5
      desired_capacity = 5
      instance_types   = ["t3.medium"]
    }
  ]

  map_users = [
    {
      userarn  = data.aws_iam_user.sample.arn
      username = data.aws_iam_user.sample.user_name
      groups   = ["system:masters"]
    },
  ]
}

data "tls_certificate" "cluster" {
  url = local.issuer_url
}

resource "aws_iam_openid_connect_provider" "training-cluster" {
  url = local.issuer_url

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
}
