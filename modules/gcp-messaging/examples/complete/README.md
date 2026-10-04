# Complete example (GCP)

Calls [`gcp-messaging`](../../README.md) directly (one fully customized instance)
and through its [wrapper](../../wrappers/README.md) (several instances from
one block). Runs unchanged against the local emulator and the real cloud:

```bash
set -a; source ../../../../.env; set +a   # emulator endpoints; skip for the real cloud
terraform init
# floci-gcp does not emulate Cloud Billing: pass the project number it returns
terraform apply -var project_number="$(curl -s http://localhost:4588/v1/projects/floci-local | jq -r .projectNumber)"
terraform destroy -var project_number="$(curl -s http://localhost:4588/v1/projects/floci-local | jq -r .projectNumber)"
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 8.5.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_events"></a> [events](#module\_events) | ../../wrappers | n/a |
| <a name="module_orders"></a> [orders](#module\_orders) | ../../ | n/a |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of every name created by this example. | `string` | `"lt-example"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID (floci-gcp accepts any ID). | `string` | `"floci-local"` | no |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | GCP project number; null looks it up (floci-gcp cannot, as it does not emulate Cloud Billing). | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_events"></a> [events](#output\_events) | Topic ID and subscription names of every wrapper item. |
| <a name="output_orders_subscriptions"></a> [orders\_subscriptions](#output\_orders\_subscriptions) | Name of every orders subscription. |
| <a name="output_orders_topic_id"></a> [orders\_topic\_id](#output\_orders\_topic\_id) | ID of the orders topic. |
<!-- END_TF_DOCS -->
