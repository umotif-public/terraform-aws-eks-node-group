![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/umotif-public/terraform-aws-eks-node-group?style=social)

# terraform-aws-eks-node-group
Terraform module to provision EKS Managed Node Group

## Resources created

This module will create EKS managed Node Group that will join your existing Kubernetes cluster. It supports use of launch template which will allow you to further enhance and modify worker nodes.

## Terraform versions

Terraform 0.12. Pin module version to `~> v4.0`. Submit pull-requests to `master` branch.

## Usage

```hcl
module "eks-node-group" {
  source = "umotif-public/eks-node-group/aws"
  version = "~> 4.0.0"

  cluster_name = aws_eks_cluster.cluster.id

  node_group_name_prefix = "eks-test-"

  subnet_ids = ["subnet-1","subnet-2","subnet-3"]

  desired_size = 1
  min_size     = 1
  max_size     = 1

  instance_types = ["t3.large","t2.large"]
  capacity_type  = "SPOT"

  ec2_ssh_key = "eks-test"

  labels = {
    lifecycle = "OnDemand"
  }

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

  force_update_version = true

  tags = {
    Environment = "test"
  }
}
```

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.43 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.43 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.main_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.main_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.main_AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [random_id.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_release_version"></a> [ami\_release\_version](#input\_ami\_release\_version) | AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version | `string` | `null` | no |
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values: `AL2_x86_64`, `AL2_x86_64_GPU`. Terraform will only perform drift detection if a configuration value is provided | `string` | `null` | no |
| <a name="input_capacity_type"></a> [capacity\_type](#input\_capacity\_type) | Type of capacity associated with the EKS Node Group. Defaults to ON\_DEMAND. Valid values: ON\_DEMAND, SPOT. | `string` | `"ON_DEMAND"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Create IAM role for node group. Set to false if pass `node_role_arn` as an argument | `bool` | `true` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | Desired number of worker nodes | `number` | n/a | yes |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided | `number` | `null` | no |
| <a name="input_ec2_ssh_key"></a> [ec2\_ssh\_key](#input\_ec2\_ssh\_key) | SSH key name that should be used to access the worker nodes | `string` | `null` | no |
| <a name="input_force_update_version"></a> [force\_update\_version](#input\_force\_update\_version) | Force version update if existing pods are unable to be drained due to a pod disruption budget issue. | `bool` | `false` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | List of instance types associated with the EKS Node Group. Terraform will only perform drift detection if a configuration value is provided | `list(string)` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed | `map(string)` | `{}` | no |
| <a name="input_launch_template"></a> [launch\_template](#input\_launch\_template) | Configuration block with Launch Template settings. `name`, `id` and `version` parameters are available. | `map(string)` | `{}` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of worker nodes | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of worker nodes | `number` | n/a | yes |
| <a name="input_node_group_name"></a> [node\_group\_name](#input\_node\_group\_name) | The name of the cluster node group. Defaults to <cluster\_name>-<random value> | `string` | `null` | no |
| <a name="input_node_group_name_prefix"></a> [node\_group\_name\_prefix](#input\_node\_group\_name\_prefix) | Creates a unique name beginning with the specified prefix. Conflicts with node\_group\_name | `string` | `null` | no |
| <a name="input_node_group_role_name"></a> [node\_group\_role\_name](#input\_node\_group\_role\_name) | The name of the cluster node group role. Defaults to <cluster\_name>-managed-group-node | `string` | `""` | no |
| <a name="input_node_role_arn"></a> [node\_role\_arn](#input\_node\_role\_arn) | IAM role arn that will be used by managed node group | `string` | `""` | no |
| <a name="input_source_security_group_ids"></a> [source\_security\_group\_ids](#input\_source\_security\_group\_ids) | Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes. If you specify `ec2_ssh_key`, but do not specify this configuration when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0) | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs to launch resources in | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags (key-value pairs) passed to resources. | `map(string)` | `{}` | no |
| <a name="input_taints"></a> [taints](#input\_taints) | List of objects containing Kubernetes taints which will be applied to the nodes in the node group. Maximum of 50 taints per node group. | `list(object({ key = string, value = any, effect = string }))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | IAM role ARN used by node group. |
| <a name="output_iam_role_id"></a> [iam\_role\_id](#output\_iam\_role\_id) | IAM role ID used by node group. |
| <a name="output_node_group"></a> [node\_group](#output\_node\_group) | Outputs from EKS node group. See `aws_eks_node_group` Terraform documentation for values |
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
