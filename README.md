# terraform-aws-eks-node-group
Terraform module to provision EKS Managed Node Group

## Resources created

This module will create EKS managed Node Group that will join your existing Kubernetes cluster. It supports use of launch template which will allow you to further enhance and modify worker nodes.

## Terraform versions

Terraform 0.12. Pin module version to `~> v3.0`. Submit pull-requests to `master` branch.

## Usage

```hcl
module "eks-node-group" {
  source = "umotif-public/eks-node-group/aws"
  version = "~> 3.0.0"

  cluster_name = aws_eks_cluster.cluster.id

  subnet_ids = ["subnet-1","subnet-2","subnet-3"]

  desired_size = 1
  min_size     = 1
  max_size     = 1

  instance_types = ["t3.large"]

  ec2_ssh_key = "eks-test"

  kubernetes_labels = {
    lifecycle = "OnDemand"
  }

  force_update_version = true

  tags = {
    Environment = "test"
  }
}
```

## Assumptions

Module is to be used with Terraform > 0.13. Fully working with Terraform 0.12 as well.

## Examples

* [EKS Node Group- single](https://github.com/umotif-public/terraform-aws-eks-node-group/tree/master/examples/single-node-group)
* [EKS Node Group- multiple az setup](https://github.com/umotif-public/terraform-aws-eks-node-group/tree/master/examples/multiaz-node-group)
* [EKS Node Group- single named node group](https://github.com/umotif-public/terraform-aws-eks-node-group/tree/master/examples/single-named-node-group)
* [EKS Node Group- single with launch template](https://github.com/umotif-public/terraform-aws-eks-node-group/tree/master/examples/single-node-group-with-launch-template)

## Authors

Module managed by [Marcin Cuber](https://github.com/marcincuber) [LinkedIn](https://www.linkedin.com/in/marcincuber/).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.6, < 0.14 |
| aws | >= 2.63, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.63, < 4.0 |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_release\_version | AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version | `string` | `null` | no |
| ami\_type | Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to `AL2_x86_64`. Valid values: `AL2_x86_64`, `AL2_x86_64_GPU`. Terraform will only perform drift detection if a configuration value is provided | `string` | `"AL2_x86_64"` | no |
| cluster\_name | The name of the EKS cluster | `string` | n/a | yes |
| create\_iam\_role | Create IAM role for node group. Set to false if pass `node_role_arn` as an argument | `bool` | `true` | no |
| desired\_size | Desired number of worker nodes | `number` | n/a | yes |
| disk\_size | Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided | `number` | `20` | no |
| ec2\_ssh\_key | SSH key name that should be used to access the worker nodes | `string` | `null` | no |
| enabled | Whether to create the resources. Set to `false` to prevent the module from creating any resources | `bool` | `true` | no |
| force\_update\_version | Force version update if existing pods are unable to be drained due to a pod disruption budget issue. | `bool` | `false` | no |
| instance\_types | Set of instance types associated with the EKS Node Group. Defaults to ["t3.medium"]. Terraform will only perform drift detection if a configuration value is provided | `list(string)` | <pre>[<br>  "t3.medium"<br>]</pre> | no |
| kubernetes\_labels | Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed | `map(string)` | `{}` | no |
| kubernetes\_version | Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided | `string` | `null` | no |
| max\_size | Maximum number of worker nodes | `number` | n/a | yes |
| min\_size | Minimum number of worker nodes | `number` | n/a | yes |
| node\_group\_name | The name of the cluster node group. Defaults to <cluster\_name>-<random value> | `string` | `""` | no |
| node\_group\_role\_name | The name of the cluster node group role. Defaults to <cluster\_name>-managed-group-node | `string` | `""` | no |
| node\_role\_arn | IAM role arn that will be used by managed node group | `string` | `""` | no |
| source\_security\_group\_ids | Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes. If you specify `ec2_ssh_key`, but do not specify this configuration when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0) | `list(string)` | `[]` | no |
| subnet\_ids | A list of subnet IDs to launch resources in | `list(string)` | n/a | yes |
| tags | A map of tags (key-value pairs) passed to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | IAM role ARN used by node group. |
| iam\_role\_id | IAM role ID used by node group. |
| node\_group | Outputs from EKS node group. See `aws_eks_node_group` Terraform documentation for values |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

See LICENSE for full details.

## Pre-commit hooks

### Install dependencies

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/segmentio/terraform-docs) required for `terraform_docs` hooks.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.

##### MacOS

```bash
brew install pre-commit terraform-docs tflint

brew tap git-chglog/git-chglog
brew install git-chglog
```
