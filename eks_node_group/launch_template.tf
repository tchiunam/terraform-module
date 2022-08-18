resource "aws_launch_template" "worker" {
  name = "${var.environment}-${var.cluster_name}-worker-${var.name}"
  description = "Launch template for worker nodes"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = "60"
      volume_type = "gp3"
      iops = 3000
      throughput = 150
      encrypted = true
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.worker.arn
  }

  image_id = var.ami_id
  instance_type = var.instance_type
  ebs_optimized = true
  vpc_security_group_ids = var.vpc_security_group_ids

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "optional"
    http_put_response_hop_limit = "2"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
        var.default_tags,
        {
        Name = "${var.environment}-${var.cluster_name}-worker-${var.name}"
        }
    )
  }
}
