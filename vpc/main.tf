resource "aws_vpc" "vpc" {
  cidr_block           = "var.vpc_cidr_block"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-${var.vpc_name}"
    }
  )
}

resource "aws_security_group" "default" {
  name        = "${var.environment}-vpc-${var.vpc_name}"
  description = "Default security group for vpc"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-vpc-${var.vpc_name}"
    }
  )
}

resource "aws_security_group_rule" "ingress_allow_tcp" {
  security_group_id = aws_security_group.default.id
  description       = "Allow all incoming TCP traffic from port 22"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
}

resource "aws_security_group_rule" "egress_allow_all" {
  security_group_id = aws_security_group.default.id
  description       = "Allow all outgoing traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
}
