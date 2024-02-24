#-----------------------------------------------------------------------------------------------------------
# Global variables
#-----------------------------------------------------------------------------------------------------------

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "app" {
  type    = string
  default = "pytest"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "group" {
  type    = string
  default = "devops"
}

variable "owner" {
  type    = string
  default = "akrish"
}

#-----------------------------------------------------------------------------------------------------------
# EKS variables
#-----------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
  default     = null
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "authentication_mode" {
  description = "The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP`"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
  default     = ""
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

## Access Entry

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = false
}

variable "readonly_role_arn" {
  description = "Role arn for the readonly access, It can be the role arn of SSO permission set or custom role that needs to be assumed by the users for the access"
  type        = string
  default     = null
}

variable "readonly_policy_arn" {
  description = "Access Entry policy arn for the readonly role, refer this link: https://aws.amazon.com/blogs/containers/a-deep-dive-into-simplified-amazon-eks-access-management-controls/#:~:text=aws%20eks%20list%2Daccess%2Dpolicies"
  type        = string
  default     = null
}

## Node group variables

variable "name" {
  description = "Name of the EKS managed node group"
  type        = string
  default     = ""
}

variable "min_size" {
  description = "Minimum number of instances/nodes"
  type        = number
  default     = 0
}

variable "max_size" {
  description = "Maximum number of instances/nodes"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "Desired number of instances/nodes"
  type        = number
  default     = 1
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values"
  type        = string
  default     = null
}

variable "capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: `ON_DEMAND`, `SPOT`"
  type        = string
  default     = "ON_DEMAND"
}

variable "instance_types" {
  description = "Set of instance types associated with the EKS Node Group. Defaults to `[\"t3.medium\"]`"
  type        = list(string)
  default     = null
}

variable "labels" {
  description = "Key-value map of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "The Kubernetes taints to be applied to the nodes in the node group. Maximum of 50 taints per node group"
  type        = any
  default     = {}
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
  type        = any
  default = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 20
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    }
  }
}

## Security group

variable "create_cluster_security_group" {
  description = "Determines if a security group is created for the cluster. Note: the EKS service creates a primary security group for the cluster by default"
  type        = bool
  default     = true
}

variable "cluster_security_group_name" {
  description = "Name to use on cluster security group created"
  type        = string
  default     = null
}

variable "create_node_security_group" {
  description = "Determines whether to create a security group for the node groups or use the existing `node_security_group_id`"
  type        = bool
  default     = true
}

variable "node_security_group_name" {
  description = "Name to use on node security group created"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate"
  type        = list(string)
  default     = []
}

## Karpenter variables
variable "create_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = false
}

variable "node_iam_role_arn" {
  description = "Existing IAM role ARN for the IAM instance profile. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "enable_spot_termination" {
  description = "Determines whether to enable native spot termination handling"
  type        = bool
  default     = true
}

## Karpenter Helm Variables

variable "create_namespace" {
  description = "Create the namespace if it does not yet exist."
  type        = bool
  default     = true
}

variable "chart" {
  description = "Chart name to be installed. "
  type        = string
  default     = "karpenter"
}

variable "chart_version" {
  description = "Specify the exact chart version to install."
  type        = string
  default     = "v0.33.0"
}

variable "namespace" {
  description = "The namespace to install the release into."
  type        = string
  default     = "karpenter"
}

variable "release_name" {
  description = "Release name. The length must not be longer than 53 characters."
  type        = string
  default     = "karpenter"
}

variable "repository" {
  description = "Repository URL where to locate the requested chart."
  type        = string
  default     = "oci://public.ecr.aws/karpenter"
}

variable "set_values" {
  description = "A map of key/value to override the chart values. The key must be the path/name of the chart value, e.g: `path.to.chart.key`"
  type        = map(string)
  default     = {}
}

