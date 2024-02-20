locals {
  irsa_role_policies = var.enable_spot_termination ? concat([module.KarpenterControllerPolicy.arn], [tostring(module.KarpenterControllerPolicySQS[0].arn)]) : [module.KarpenterControllerPolicy.arn]
  node_iam_roles_arn = [for group in module.eks.eks_managed_node_groups : group.iam_role_arn]
}
