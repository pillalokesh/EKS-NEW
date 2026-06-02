output "irsa_role_arns" {
  value = { for k, v in aws_iam_role.irsa : k => v.arn }
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "secrets_reader_policy_arn" {
  value = aws_iam_policy.secrets_reader.arn
}
