################################################################################
# AMI Data Source (conditional - used when ami_id is not provided)
################################################################################

data "aws_ami" "amazon_linux" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for ${local.name_prefix} EC2 instances"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-sg"
    },
  )
}

resource "aws_security_group_rule" "ingress" {
  for_each = local.ingress_rules

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" { #trivy:ignore:AVD-AWS-0104 -- Egress rules are user-configurable
  for_each = local.egress_rules

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
  security_group_id = aws_security_group.this.id
}

################################################################################
# EC2 Instances
################################################################################

resource "aws_instance" "this" {
  for_each = local.instance_keys

  ami                         = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux[0].id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name
  user_data                   = var.user_data
  iam_instance_profile        = var.iam_instance_profile

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = var.root_volume_encrypted
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.key}"
    },
  )

  lifecycle {
    ignore_changes = [ami]
  }
}

################################################################################
# Additional EBS Volumes
################################################################################

resource "aws_ebs_volume" "this" {
  for_each = local.instance_volume_pairs

  availability_zone = aws_instance.this[each.value.instance_key].availability_zone
  size              = each.value.volume.size
  type              = each.value.volume.type
  encrypted         = each.value.volume.encrypted

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ebs-${each.key}"
    },
  )
}

resource "aws_volume_attachment" "this" {
  for_each = local.instance_volume_pairs

  device_name = each.value.volume.device_name
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this[each.value.instance_key].id
}
