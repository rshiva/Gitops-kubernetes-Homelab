outputs "cluster_endpoint"{
  value = aws_eks_cluster_main.cluster_endpoint
}

output "cluster_ca_certificate"{
   value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_name"{
  value = aws_eks_cluster.main.name
}

output "oidc_provider_arn" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer_arn
}
