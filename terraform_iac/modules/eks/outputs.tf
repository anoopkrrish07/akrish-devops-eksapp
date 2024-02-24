output "cluster_name" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready."
  value       = module.eks.cluster_name
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks.cluster_version
}

output "cluster_oidc_issuer_url" {
  description = "Outputs from EKS node groups. Map of maps, keyed by var.node_groups keys"
  value       = module.eks.cluster_oidc_issuer_url
}

output "Karpenter_IRSA_Role_ARN" {
  description = "Karpenter IRSA Role ARN"
  value       = module.KarpenterControllerIRSA.iam_role_arn
}

output "EKS_managed_node_role_arns" {
  description = "IAM role ARNs of the EKS nodes."
  value       = [for group in module.eks.eks_managed_node_groups : group.iam_role_arn]
}

output "Karpenter_node_instance_profile" {
  description = "instanceProfile for Karpenter to launch nodes"
  value       = module.eks_karpenter.instance_profile_name
}

output "KarpenterSQSName" {
  description = "Karpenter Interruption SQS Name"
  value       = module.eks_karpenter.queue_name
}

# ECR variables
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value = aws_ecr_repository.ecr.repository_url
}
