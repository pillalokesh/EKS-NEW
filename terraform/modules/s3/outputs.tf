output "app_storage_bucket_name" {
  value = aws_s3_bucket.app_storage.bucket
}

output "app_storage_bucket_arn" {
  value = aws_s3_bucket.app_storage.arn
}

output "velero_bucket_name" {
  value = aws_s3_bucket.velero.bucket
}

output "velero_bucket_arn" {
  value = aws_s3_bucket.velero.arn
}
