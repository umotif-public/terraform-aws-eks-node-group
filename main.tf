resource "random_id" "main" {
  count = var.enabled ? 1 : 0

  byte_length = 4

  keepers = {
    ami_type       = var.ami_type
    disk_size      = var.disk_size
    instance_types = join("|", var.instance_types)
    node_role_arn  = var.node_role_arn

    ec2_ssh_key               = var.ec2_ssh_key
    source_security_group_ids = join("|", var.source_security_group_ids)

    subnet_ids   = join("|", var.subnet_ids)
    cluster_name = var.cluster_name
  }
}

resource "aws_eks_node_group" "main" {
  count = var.enabled ? 1 : 0

  cluster_name    = var.cluster_name
  node_group_name = join("-", [var.cluster_name, random_id.main[0].hex])
  node_role_arn   = var.node_role_arn == "" ? join("", aws_iam_role.main.*.arn) : var.node_role_arn

  subnet_ids = var.subnet_ids

  ami_type       = var.ami_type
  disk_size      = var.disk_size
  instance_types = var.instance_types
  labels         = var.kubernetes_labels

  release_version = var.ami_release_version
  version         = var.kubernetes_version

  tags = var.tags

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  dynamic "remote_access" {
    for_each = var.ec2_ssh_key != null && var.ec2_ssh_key != "" ? ["true"] : []
    content {
      ec2_ssh_key               = var.ec2_ssh_key
      source_security_group_ids = var.source_security_group_ids
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }
}

resource "aws_iam_role" "main" {
  count = var.enabled && var.create_iam_role ? 1 : 0

  name = "${var.cluster_name}-managed-group-node"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main_AmazonEKSWorkerNodePolicy" {
  count = var.enabled && var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.main[0].name
}

resource "aws_iam_role_policy_attachment" "main_AmazonEKS_CNI_Policy" {
  count = var.enabled && var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.main[0].name
}

resource "aws_iam_role_policy_attachment" "main_AmazonEC2ContainerRegistryReadOnly" {
  count = var.enabled && var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.main[0].name
}
