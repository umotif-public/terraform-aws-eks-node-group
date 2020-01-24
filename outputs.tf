output "iam_role_arn" {
  description = "IAM role ARN used by node group."
  value       = join("", aws_iam_role.main.*.arn)
}

output "iam_role_id" {
  description = "IAM role ID used by node group."
  value       = join("", aws_iam_role.main.*.id)
}

output "node_group" {
  description = "Outputs from EKS node group. See `aws_eks_node_group` Terraform documentation for values"
  value       = aws_eks_node_group.main
}
