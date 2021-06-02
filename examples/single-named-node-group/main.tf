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
# EKS Node Group
#####
module "eks-node-group" {
  source = "../../"

  node_group_name      = "example-nodegroup"
  node_group_role_name = "example-nodegroup"

  cluster_name = aws_eks_cluster.cluster.id

  subnet_ids = data.aws_subnet_ids.all.ids

  desired_size = 1
  min_size     = 1
  max_size     = 1

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
  }

  tags = {
    Environment = "test"
  }
}
