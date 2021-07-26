data "aws_caller_identity" "self" {}

data "aws_iam_policy_document" "training" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GenerateCredentialReport",
      "autoscaling:Describe*",
      "iam:List*",
      "ssm:GetConnectionStatus",
      "iam:GenerateServiceLastAccessedDetails",
      "cloudwatch:List*",
      "cloudwatch:Describe*",
      "sn:List*",
      "iam:Get*",
      "iam:SimulatePrincipalPolicy",
      "iam:SimulateCustomPolicy",
      "sns:Get*",
      "ssm:DescribeInstanceInformation",
      "cloudwatch:Get*"
    ]
    resources = ["*"]
  }


  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "ssm:StartSession"
    ]
    resources = [
      "arn:aws:ec2:us-east-1:${data.aws_caller_identity.self.account_id}:instance/*",
      "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/AllowSSM"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "rds:*",
      "elasticloadbalancing:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:ResumeSession",
      "ssm:TerminateSession"
    ]
    resources = ["arn:aws:ssm:*:*:session/&{aws:username}-*"]
  }
}

resource "aws_iam_policy" "training" {
  name   = "training"
  policy = data.aws_iam_policy_document.training.json
}


