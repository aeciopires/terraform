# Complete example (AWS)

Calls [`aws-messaging`](../../README.md) directly (one fully customized instance)
and through its [wrapper](../../wrappers/README.md) (several instances from
one block). Runs unchanged against the local emulator and the real cloud:

```bash
set -a; source ../../../../.env; set +a   # emulator endpoints; skip for the real cloud
terraform init
terraform apply
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.67.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_events"></a> [events](#module\_events) | ../../wrappers | n/a |
| <a name="module_orders"></a> [orders](#module\_orders) | ../../ | n/a |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of every name created by this example. | `string` | `"lt-example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_events"></a> [events](#output\_events) | Topic ARN and queue names of every wrapper item. |
| <a name="output_orders_queue_urls"></a> [orders\_queue\_urls](#output\_orders\_queue\_urls) | URL of every orders queue. |
| <a name="output_orders_topic_arn"></a> [orders\_topic\_arn](#output\_orders\_topic\_arn) | ARN of the orders topic. |
<!-- END_TF_DOCS -->
