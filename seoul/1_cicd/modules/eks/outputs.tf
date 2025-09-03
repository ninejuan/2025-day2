output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS 클러스터 이름"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "EKS 클러스터 CA 인증서"
  value       = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
}

output "cluster_token" {
  description = "EKS 클러스터 토큰"
  value       = data.aws_eks_cluster_auth.main.token
}

output "node_group_name" {
  description = "EKS Node Group 이름"
  value       = aws_eks_node_group.main.node_group_name
}
