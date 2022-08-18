locals {
  subnet_privates = merge(var.subnet_private_general, var.subnet_private_pii)
}

resource "aws_internet_group" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(aws_vpc.vpc.tags, "Name")}-igw"
    }
  )
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]

  for_each = var.subnet_publics

  vpc = true

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-eip-${var.subnet_publics[each.key].name}"
    }
  )
}

resource "aws_subnet" "publics" {
  for_each          = var.subnet_publics
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_publics[each.key].cidr_block
  availability_zone = var.subnet_publics[each.key].availability_zone

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-subnet-${var.subnet_publics[each.key].name}"
    }
  )
}

resource "aws_nat_gateway" "ngw" {
  depends_on = [aws_internet_gateway.igw, aws_subnet.publics]

  for_each = var.subnet_publics

  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = aws_subnet.publics[each.key].id

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-ngw-${var.subnet_publics[each.key].name}"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(aws_vpc.vpc.tags, "Name")}-public"
    }
  )
}

resource "aws_route_table_association" "public" {
  depends_on = [aws_subnet.publics, aws_route_table.public]

  for_each       = var.subnet_publics
  subnet_id      = aws_subnet.publics[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public" {
  depends_on = [aws_internet_gateway.igw, aws_route_table.public]

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "privates" {
  for_each          = locals.subnet_privates
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnet_privates[each.key].cidr_block
  availability_zone = local.subnet_privates[each.key].availability_zone

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-subnet-${locals.subnet_privates[each.key].name}"
    }
  )
}
