module "eks_karpenter" {
  #depends_on       = [module.eks]
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.2.1"

  cluster_name            = module.eks.cluster_name
  create_iam_role         = var.create_iam_role
  node_iam_role_arn       = module.eks.eks_managed_node_groups["karpenter_node"].iam_role_arn
  enable_spot_termination = var.enable_spot_termination
  create_access_entry     = false

  tags = merge(var.tags, {
    owner    = var.owner
    env      = var.env
    group    = var.group
    terrform = "true"
  })

}

## Karpenter Controller IRSA Policy
module "KarpenterControllerPolicy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.34.0"

  name        = "KarpenterControllerPolicy-${module.eks.cluster_name}"
  description = "EKS Service account policy for Karpenter"
  policy      = data.aws_iam_policy_document.KarpenterControllerPolicyDocument.json

  tags = merge(var.tags, {
    owner    = var.owner
    env      = var.env
    group    = var.group
    terrform = "true"
  })
}

## Karpenter Controller IRSA SQS Policy
module "KarpenterControllerPolicySQS" {
  count = var.enable_spot_termination ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.34.0"

  name        = "KarpenterControllerPolicySQS-${module.eks.cluster_name}"
  description = "EKS Service account policy for Karpenter SQS"
  policy      = data.aws_iam_policy_document.sqs_irsa[0].json

  tags = merge(var.tags, {
    owner    = var.owner
    env      = var.env
    group    = var.group
    terrform = "true"
  })
}

## Karpenter Controller IRSA Assumable Role
module "KarpenterControllerIRSA" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.34.0"

  create_role      = true
  role_description = "EKS SA role for Karpenter"
  role_name        = "KarpenterControllerIRSA-${module.eks.cluster_name}"
  provider_url     = module.eks.cluster_oidc_issuer_url
  role_policy_arns = local.irsa_role_policies
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${var.namespace}:${var.release_name}"
  ]
  oidc_fully_qualified_audiences = [
    "sts.amazonaws.com"
  ]

  tags = merge(var.tags, {
    app      = var.app
    env      = var.env
    group    = var.group
    terrform = "true"
  })
}

## Karpenter tags(discovery) for worker subnet
resource "aws_ec2_tag" "karpenter_subnet_tag" {
  count       = length(data.aws_subnets.private.ids)
  resource_id = data.aws_subnets.private.ids[count.index]
  key         = "karpenter.sh/discovery"
  value       = module.eks.cluster_name
}

## Karpenter Helm installation
resource "helm_release" "karpenter" {
  depends_on       = [module.eks.eks_managed_node_groups]
  namespace        = var.namespace
  version          = var.chart_version
  name             = var.release_name
  repository       = var.repository
  chart            = var.chart
  create_namespace = var.create_namespace

  dynamic "set" {
    for_each = var.set_values

    content {
      name  = set.key
      value = set.value
    }
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.KarpenterControllerIRSA.iam_role_arn
  }

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.interruptionQueueName"
    value = var.enable_spot_termination ? module.eks_karpenter.queue_name : ""
  }

  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }

  set {
    name  = "tolerations[0].key"
    value = "dedicated"
  }

  set {
    name  = "tolerations[0].value"
    value = "karpenter-controller"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }
}
