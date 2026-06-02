output "eks_kms_key_arn" {
  value = aws_kms_key.eks.arn
}

output "rds_kms_key_arn" {
  value = aws_kms_key.rds.arn
}

output "s3_kms_key_arn" {
  value = aws_kms_key.s3.arn
}

output "secrets_kms_key_arn" {
  value = aws_kms_key.secrets.arn
}

output "eks_kms_key_id" {
  value = aws_kms_key.eks.key_id
}
