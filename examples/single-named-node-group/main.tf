provider "aws" {
  region = "eu-west-1"
}

#####
# VPC and subnets
#####
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = "simple-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_nat_gateway     = true
  enable_vpn_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    "kubernetes.io/cluster/eks" = "shared",
    Environment                 = "test"
  }
}

#####
# EKS Cluster
#####

resource "aws_eks_cluster" "cluster" {
  enabled_cluster_log_types = []
  name                      = "eks"
  role_arn                  = aws_iam_role.cluster.arn
  version                   = "1.14"

  vpc_config {
    subnet_ids              = flatten([module.vpc.public_subnets, module.vpc.private_subnets])
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

  enabled      = true
  cluster_name = aws_eks_cluster.cluster.id

  subnet_ids = flatten([module.vpc.private_subnets])

  desired_size = 1
  min_size     = 1
  max_size     = 1

  ec2_ssh_key = "eks-test"

  kubernetes_labels = {
    lifecycle = "OnDemand"
  }

  tags = {
    Environment = "test"
  }
}
