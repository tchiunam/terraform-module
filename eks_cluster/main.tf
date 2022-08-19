resource "aws_eks_cluster" "cluster" {
  depends_on = [
    aws_iam_role_policy_attachment.eks_service,
    aws_iam_role_policy_attachment.eks_cluster,
    aws_cloudwatch_log_group.cluster
  ]

  name     = "${var.environment}-${var.name}"
  version  = var.version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    endpoint_private_access = true
    security_group_ids      = []
    subnet_ids              = var.subnet_ids
  }

  # Public access fro SaaS CICD tools
  endpoint_private_access = true
  public_access_cidrs     = ["0.0.0.0/0"]

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.cluster.arn
    }
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-vpc-${var.name}"
    }
  )
}

resource "aws_iam_role" "cluster" {
  name               = "${var.environment}-eks-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.cluster.json

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-eks-${var.name}"
    }
  )
}

data "aws_iam_policy_document" "cluster" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "cluster" {
  description = "KMS key for EKS cluster"

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-eks-${var.name}"
    }
  )
}

resource "aws_iam_role" "eks_service" {
  name               = "${var.environment}-eks-${var.name}-service"
  assume_role_policy = data.aws_iam_policy_document.eks_service_assume_role.json

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-eks-${var.name}-service"
    }
  )
}

data "aws_iam_policy_document" "eks_service_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_service" {
  role       = aws_iam_role.eks_service.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_ServicePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_ClusterPolicy"
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.environment}-${var.name}/cluster"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.default_tags,
    {
      Name = "/aws/eks/${var.environment}-${var.name}/cluster"
    }
  )
}

resource "aws_iam_policy" "eks_cloudwatch" {
  name   = "${var.environment}-eks-${var.name}-cloudwatch"
  policy = data.aws_iam_policy_document.eks_cloudwatch.json

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-eks-${var.name}-cloudwatch"
    }
  )
}

data "aws_iam_policy_document" "eks_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy"
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/eks/${var.environment}-${var.name}/cluster"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:*"]
  }
}
