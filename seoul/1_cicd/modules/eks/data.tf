# EKS 클러스터 인증 데이터
data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}
