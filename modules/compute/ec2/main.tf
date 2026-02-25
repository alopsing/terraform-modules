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
  count = length(var.ingress_rules)

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_blocks
  description       = var.ingress_rules[count.index].description
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" { #trivy:ignore:AVD-AWS-0104 -- Egress rules are user-configurable
  count = length(var.egress_rules)

  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = var.egress_rules[count.index].cidr_blocks
  description       = var.egress_rules[count.index].description
  security_group_id = aws_security_group.this.id
}

################################################################################
# EC2 Instances
################################################################################

resource "aws_instance" "this" {
  count = var.instance_count

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
      Name = "${local.name_prefix}-${count.index + 1}"
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
  count = var.instance_count * length(var.additional_ebs_volumes)

  availability_zone = aws_instance.this[floor(count.index / length(var.additional_ebs_volumes))].availability_zone
  size              = var.additional_ebs_volumes[count.index % length(var.additional_ebs_volumes)].size
  type              = var.additional_ebs_volumes[count.index % length(var.additional_ebs_volumes)].type
  encrypted         = var.additional_ebs_volumes[count.index % length(var.additional_ebs_volumes)].encrypted

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ebs-${floor(count.index / length(var.additional_ebs_volumes)) + 1}-${count.index % length(var.additional_ebs_volumes)}"
    },
  )
}

resource "aws_volume_attachment" "this" {
  count = var.instance_count * length(var.additional_ebs_volumes)

  device_name = var.additional_ebs_volumes[count.index % length(var.additional_ebs_volumes)].device_name
  volume_id   = aws_ebs_volume.this[count.index].id
  instance_id = aws_instance.this[floor(count.index / length(var.additional_ebs_volumes))].id
}
