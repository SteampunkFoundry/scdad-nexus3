# scdad-nexus3

Provisions a server for SCDAD and deploys Nexus 3 on to it.

Provision the server and VPC using Terraform:

```console
$ terraform plan
$ terraform apply
...
Outputs:

nexus3_ip = "18.204.176.48"
```

Copy the `nexus3_ip` value into `hosts`:

```text
18.204.176.48

[nexus3]
18.204.176.48
```

Install Sonatype Nexus 3 using Ansible:

```shell
$ ansible-galaxy install geerlingguy.java
$ ansible-galaxy install ansible-thoteam.nexus3-oss
$ ansible-playbook -i hosts --private-key=~/.ssh/ansible scdad-nexus3.yml
```

# Terraform docs
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.32.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.32.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.gitlab_eip0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.gitlab_eip1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_instance.gitlab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.scdad_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route_table.rtb_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.rta_subnet_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.gitlab_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.scdad_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_flow_logs_log_arn"></a> [aws\_flow\_logs\_log\_arn](#input\_aws\_flow\_logs\_log\_arn) | ARN for the CloudWatch Log group for publishing flow logs | `string` | n/a | yes |
| <a name="input_aws_flow_logs_role_arn"></a> [aws\_flow\_logs\_role\_arn](#input\_aws\_flow\_logs\_role\_arn) | ARN for the IAM role for publishing flow logs- https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html | `string` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | Local AWS profile to use for AWS credentials | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to build in | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gitlab_ip0"></a> [gitlab\_ip0](#output\_gitlab\_ip0) | The elastic IP address of the first gitlab instance. |
| <a name="output_gitlab_ip1"></a> [gitlab\_ip1](#output\_gitlab\_ip1) | The elastic IP address of the second gitlab instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
