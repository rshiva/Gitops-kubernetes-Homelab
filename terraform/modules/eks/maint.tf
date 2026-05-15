locals {
  name_prefix = "${var.project_name}-${var.env}"
}
# cluster IAM Roles
#
resource "aws_iam_role" "cluster_role"{
  name = "${local.name_prefix}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = { Name = "${local.name_prefix}-cluster-iam-role"}

}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy"{
  role = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

# Node group IAM Role
resource "aws_iam_role" "node_role"{
  name = "${local.name_prefix}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com","eks.amazonaws.com"]
        }
      }
    ]
  })

  tags = { Name = "${local.name_prefix}-node-iam-role"}

}

# Nodes need 3 managed policies to join the cluster and function
resource "aws_iam_role_policy_attachment" "node_worker_policy"{
  role = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# EKS cluster

resource "aws_eks_cluster" "main"{

  name = "${local.name_prefix}-eks-cluster"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
    tags = { Name = "${local.name_prefix}-eks-cluster"}
}


# EKS Managed Node Group

resource "aws_eks_node_group" "nodes"{
  cluster_name = aws_eks_cluster.main.name
  node_group_name = "${local.name_prefix}-eks-nodes"
  node_role_arn = aws_iam_role.node_role.arn
  subnet_ids = var.private_subnet_ids
  instance_types = var.instance_types

  scaling_config {
     desired_size = 2
     max_size     = 3
     min_size     = 1
   }

   depends_on = [
       aws_iam_role_policy_attachment.node_worker_policy,
       aws_iam_role_policy_attachment.node_cni_policy,
       aws_iam_role_policy_attachment.node_ecr_policy,
     ]
     tags = { Name = "${local.name_prefix}-eks-nodes-cluster"}
}

# OIDC provider — required for IRSA
#
data "tls_certificate" "eks"{
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks"{
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
