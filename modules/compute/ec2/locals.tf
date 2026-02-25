locals {
  name_prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "ec2"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  # Map for instances keyed by string number
  instance_keys = { for i in range(var.instance_count) : tostring(i + 1) => i }

  # Map for ingress rules keyed by protocol-port combination
  ingress_rules = { for i, rule in var.ingress_rules : "${rule.protocol}-${rule.from_port}-${rule.to_port}" => rule }

  # Map for egress rules keyed by protocol-port combination
  egress_rules = { for i, rule in var.egress_rules : "${rule.protocol}-${rule.from_port}-${rule.to_port}" => rule }

  # Cartesian product of instances x EBS volumes
  instance_volume_pairs = { for pair in flatten([
    for ik, iv in local.instance_keys : [
      for vi, vol in var.additional_ebs_volumes : {
        key          = "${ik}-${vi}"
        instance_key = ik
        volume_index = vi
        volume       = vol
      }
    ]
  ]) : pair.key => pair }
}
