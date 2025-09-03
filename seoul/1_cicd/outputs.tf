output "vpc_id" {
  description = "생성된 VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public 서브넷 ID들"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private 서브넷 ID들"
  value       = module.vpc.private_subnet_ids
}

output "kms_key_id" {
  description = "생성된 KMS 키 ID"
  value       = module.kms.kms_key_id
}

output "ecr_repository_url" {
  description = "ECR 레포지토리 URL"
  value       = module.ecr.repository_url
}

output "eks_cluster_id" {
  description = "EKS 클러스터 ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = module.eks.cluster_endpoint
}

output "bastion_public_ip" {
  description = "Bastion 호스트 공인 IP"
  value       = module.bastion.public_ip
}

output "github_runner_public_ip" {
  description = "Github Actions Runner 공인 IP"
  value       = module.github_runner.public_ip
}

output "ssh_key_name" {
  description = "SSH 키페어 이름"
  value       = aws_key_pair.gac_ssh.key_name
}

output "ssh_private_key" {
  description = "SSH 개인키 (base64 인코딩)"
  value       = base64encode(file("${path.module}/gac-ssh-key"))
  sensitive   = true
}


