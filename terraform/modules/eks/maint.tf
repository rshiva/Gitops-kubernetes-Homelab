locals {
  name_prefix = "${var.project_name}-${var.env}"
}
# cluster IAM Roles
#
resource "aws_iam_role" "cluster_role"{
  name = "${local.name_prefix}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2102-10-17"
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

resource "aws_iam_role_policy_attachment", "eks_cluster_policy"{
  role = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

# Node group IAM Role
resource "aws_iam_role" "node_role"{
  name = "${local.name_prefix}-node-role"

  assume_role_policy = jsonencode({
    Version = "2102-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = { Name = "${local.name_prefix}-node-iam-role"}

}

# Nodes need 3 managed policies to join the cluster and function
resource "aws_iam_role_policy_attachment", "node_worker_policy"{
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
