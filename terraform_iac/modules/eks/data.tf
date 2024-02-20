## VPC Datasource
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "all" {
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["${data.aws_vpc.main.tags.Name}-public*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${data.aws_vpc.main.tags.Name}-private*"]
  }
}

## EKS Cluster
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_ecrpublic_authorization_token" "this" {
  provider = aws.karpenter_ecr
}

## Karpenter Controller IRSA Policy Statement
data "aws_iam_policy_document" "KarpenterControllerPolicyDocument" {
  statement {
    resources = ["*"]
    actions = [
      # Write Operations
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
      "ec2:DeleteLaunchTemplate",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      # Read Operations
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "pricing:GetProducts",
      "ssm:GetParameter"
    ]
  }
  statement {
    resources = local.node_iam_roles_arn
    actions = [
      "iam:PassRole"
    ]
  }
  statement {
    resources = [module.eks.cluster_arn]
    actions = [
      "eks:DescribeCluster"
    ]
  }
}

data "aws_iam_policy_document" "sqs_irsa" {
  count = var.enable_spot_termination ? 1 : 0

  statement {
    resources = [module.eks_karpenter.queue_arn]
    actions = [
      # Write Operations
      "sqs:DeleteMessage",
      # Read Operations
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]
  }
}
