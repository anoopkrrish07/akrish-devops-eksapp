resource "random_id" "id" {
  byte_length = 2
}

module "eks" {
  # source  = "terraform-aws-modules/eks/aws"
  # version = "20.2.1"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=6c168effbe06f6e5ad4b122c7a3b491a2e1c874a"

  cluster_name                             = "${var.env}-${var.group}-${random_id.id.hex}"
  cluster_version                          = "1.28"
  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  authentication_mode                      = var.authentication_mode
  vpc_id                                   = var.vpc_id
  subnet_ids                               = concat(data.aws_subnets.public.ids, data.aws_subnets.private.ids)
  enable_cluster_creator_admin_permissions = true #if false you have to add access_entries for permission 
  enable_irsa                              = true
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }

  access_entries = {
    readonly-access = {
      #kubernetes_groups = [] #cluster role 
      principal_arn = var.readonly_role_arn

      policy_associations = {
        policy-one = {
          policy_arn = var.readonly_policy_arn
          access_scope = {
            type = "cluster" #can be namespaced
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    karpenter_node = {
      name         = "karpenter-node"
      min_size     = 1
      max_size     = 2
      desired_size = 1

      subnet_ids = data.aws_subnets.private.ids
      # ami_type       = "AL2_x86_64"
      capacity_type  = var.capacity_type
      instance_types = var.instance_types

      #vpc_security_group_ids = [module.eks.node_security_group_id]

      labels = merge(var.labels, {
        "NodeGroup" = "karpenter-node",
      })

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "karpenter-controller"
          effect = "NO_SCHEDULE"
        }
      }
      block_device_mappings = var.block_device_mappings

      tags = merge(var.tags, {
        app      = var.app
        env      = var.env
        group    = var.group
        terrform = "true"
      })
    }
  }
  ## Security group
  create_cluster_security_group = true
  cluster_security_group_name   = "cluster-security-group"
  create_node_security_group    = true
  node_security_group_name      = "node-security-group"

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes = {
      description                = "All open to worker node"
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 0
      type                       = "egress"
      source_node_security_group = true
    }
    ingress_nodes = {
      description                = "All open to worker node"
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 0
      type                       = "ingress"
      source_node_security_group = true
    }

  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = "${var.env}-${var.group}-${random_id.id.hex}"
  }

  tags = merge(var.tags, {
    app      = var.app
    env      = var.env
    group    = var.group
    terrform = "true"
  })
}
