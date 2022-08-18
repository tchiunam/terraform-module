resource "aws_eks_node_group" "eks_node_group" {
  depends_on = [
    aws_iam_role_policy_attachment.worker,
    aws_iam_role_policy_attachment.worker_cni,
    aws_iam_role_policy_attachment.worker_ecr,
    aws_iam_role_policy_attachment.worker_secretmanager
  ]

  cluster_name  = var.cluster_name
  name          = var.name
  node_role_arn = aws_iam_role.worker.arn
  subnet_ids    = var.subnet_ids

  launch_template {
    name    = aws_launch_template.worker.name
    version = aws_launch_template.worker.latest_version
  }

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }

  update_config {
    max_unavailable = 2
  }

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-${var.name}"
    }
  )
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.environment}-${var.cluster_name}-worker-${var.name}"
  role = aws_iam_role.worker.name

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-${var.cluster_name}-worker-${var.name}"
    }
  )
}

resource "aws_iam_role" "worker" {
  name               = "${var.environment}-${var.cluster_name}-worker-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.worker.json

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-${var.cluster_name}-worker-${var.name}"
    }
  )
}

data "aws_iam_policy_document" "worker" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "worker" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_cni" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "worker_ecr" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "worker_secretmanager" {
  role       = aws_iam_role.worker.name
  policy_arn = aws_iam_policy.worker_secretmanager.arn
}

data "aws_iam_policy_document" "worker_secretmanager" {
  statement {
    effect  = "Allow"
    actions = [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecrets"
        ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.secrets_name_prefix}*"
        ]
  }
}