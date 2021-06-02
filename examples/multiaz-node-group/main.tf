provider "aws" {
  region = "eu-west-1"
}

#####
# VPC and subnets
#####
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

#####
# EKS Cluster
#####
resource "aws_eks_cluster" "cluster" {
  enabled_cluster_log_types = []
  name                      = "eks-module-test-cluster"
  role_arn                  = aws_iam_role.cluster.arn
  version                   = "1.20"

  vpc_config {
    subnet_ids              = data.aws_subnet_ids.all.ids
    security_group_ids      = []
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

#####
# EKS Node Group per availability zone
# If you are running a stateful application across multiple Availability Zones that is backed by Amazon EBS volumes and using the Kubernetes Cluster Autoscaler,
# you should configure multiple node groups, each scoped to a single Availability Zone. In addition, you should enable the --balance-similar-node-groups feature.
#
# In this setup you can configure a single IAM Role that is attached to multiple node groups.
#####

resource "aws_iam_role" "main" {
  name = "eks-managed-group-node-role"

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
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "main_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "main_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.main.name
}

module "eks-node-group-a" {
  source = "../../"

  create_iam_role = false

  cluster_name = aws_eks_cluster.cluster.id

  node_group_name_prefix = "eks-test-group-ab-"
  node_role_arn          = aws_iam_role.main.arn

  subnet_ids = [sort(data.aws_subnet_ids.all.ids)[0]]

  desired_size = 1
  min_size     = 1
  max_size     = 1

  instance_types = ["t3.large"]

  ec2_ssh_key = "eks-test"

  taints = [
    {
      key    = "test-1"
      value  = null
      effect = "NO_SCHEDULE"
    },
    {
      key    = "test-2"
      value  = "value-test"
      effect = "NO_EXECUTE"
    }
  ]

  labels = {
    lifecycle = "OnDemand"
    az        = "eu-west-1a"
  }

  tags = {
    Environment = "test"
  }
}

module "eks-node-group-b" {
  source = "../../"

  create_iam_role = false

  cluster_name = aws_eks_cluster.cluster.id

  node_group_name = "eks-test-group-b"

  node_role_arn = aws_iam_role.main.arn
  subnet_ids    = [sort(data.aws_subnet_ids.all.ids)[1]]

  desired_size = 1
  min_size     = 1
  max_size     = 1

  instance_types = ["t2.large"]

  ec2_ssh_key = "eks-test"

  labels = {
    lifecycle = "OnDemand"
    az        = "eu-west-1b"
  }

  tags = {
    Environment = "test"
  }
}

module "eks-node-group-c" {
  source = "../../"

  create_iam_role = false

  cluster_name  = aws_eks_cluster.cluster.id
  node_role_arn = aws_iam_role.main.arn
  subnet_ids    = [sort(data.aws_subnet_ids.all.ids)[2]]

  desired_size = 1
  min_size     = 1
  max_size     = 1

  ec2_ssh_key = "eks-test"

  labels = {
    lifecycle = "OnDemand"
    az        = "eu-west-1c"
  }

  tags = {
    Environment = "test"
  }
}
