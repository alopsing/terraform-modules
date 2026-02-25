output "role_arns" {
  description = "Map of role names to ARNs"
  value       = { for k, v in aws_iam_role.this : k => v.arn }
}

output "role_names" {
  description = "Map of role keys to names"
  value       = { for k, v in aws_iam_role.this : k => v.name }
}

output "instance_profile_arns" {
  description = "Map of instance profile names to ARNs"
  value       = { for k, v in aws_iam_instance_profile.this : k => v.arn }
}

output "instance_profile_names" {
  description = "Map of instance profile keys to names"
  value       = { for k, v in aws_iam_instance_profile.this : k => v.name }
}

output "policy_arns" {
  description = "Map of policy names to ARNs"
  value       = { for k, v in aws_iam_policy.this : k => v.arn }
}

output "oidc_provider_arns" {
  description = "Map of OIDC provider names to ARNs"
  value       = { for k, v in aws_iam_openid_connect_provider.this : k => v.arn }
}
