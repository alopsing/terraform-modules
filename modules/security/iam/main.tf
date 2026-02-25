################################################################################
# IAM Roles
################################################################################

resource "aws_iam_role" "this" {
  for_each = var.roles

  name                 = "${local.name_prefix}-${each.key}"
  description          = each.value.description
  assume_role_policy   = each.value.assume_role_policy
  max_session_duration = each.value.max_session_duration

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
  })
}

################################################################################
# Managed Policy Attachments
################################################################################

locals {
  role_policy_attachments = flatten([
    for role_key, role in var.roles : [
      for policy_arn in role.managed_policy_arns : {
        role_key   = role_key
        policy_arn = policy_arn
      }
    ]
  ])
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = {
    for rpa in local.role_policy_attachments : "${rpa.role_key}-${rpa.policy_arn}" => rpa
  }

  role       = aws_iam_role.this[each.value.role_key].name
  policy_arn = each.value.policy_arn
}

################################################################################
# Inline Policies
################################################################################

locals {
  role_inline_policies = flatten([
    for role_key, role in var.roles : [
      for policy_name, policy in role.inline_policies : {
        role_key    = role_key
        policy_name = policy_name
        policy      = policy.policy
      }
    ]
  ])
}

resource "aws_iam_role_policy" "inline" {
  for_each = {
    for rip in local.role_inline_policies : "${rip.role_key}-${rip.policy_name}" => rip
  }

  name   = each.value.policy_name
  role   = aws_iam_role.this[each.value.role_key].id
  policy = each.value.policy
}

################################################################################
# Instance Profiles
################################################################################

resource "aws_iam_instance_profile" "this" {
  for_each = { for k, v in var.roles : k => v if v.create_instance_profile }

  name = "${local.name_prefix}-${each.key}"
  role = aws_iam_role.this[each.key].name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
  })
}

################################################################################
# IAM Policies
################################################################################

resource "aws_iam_policy" "this" {
  for_each = var.policies

  name        = "${local.name_prefix}-${each.key}"
  description = each.value.description
  path        = each.value.path
  policy      = each.value.policy

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
  })
}

################################################################################
# OIDC Providers
################################################################################

resource "aws_iam_openid_connect_provider" "this" {
  for_each = var.oidc_providers

  url             = each.value.url
  client_id_list  = each.value.client_id_list
  thumbprint_list = each.value.thumbprint_list

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
  })
}
