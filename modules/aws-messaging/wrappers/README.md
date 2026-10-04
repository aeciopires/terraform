# Wrapper for the aws-messaging module

Creates **one copy of the module per entry of `items`**. Each argument is
taken from the item, then from `defaults`, then from the module's own
default - so you write the common settings once and only the differences
per item. This is the same pattern the
[terraform-aws-modules wrappers](https://github.com/terraform-aws-modules/terraform-aws-lambda/tree/master/wrappers)
use; it is especially useful with Terragrunt, where a unit calls exactly one
module and cannot use `for_each` on it.

Resources that don't fit the loop (one-off, fully customized instances) stay
outside: call the module itself in another block or unit, as
[`../examples/complete`](../examples/complete/README.md) does.

`labels`/`tags` are **merged** (defaults + item), every other argument is
replaced as a whole.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_wrapper"></a> [wrapper](#module\_wrapper) | ../ | n/a |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_defaults"></a> [defaults](#input\_defaults) | Map of default values which will be used for each item. | `any` | `{}` | no |
| <a name="input_items"></a> [items](#input\_items) | Maps of items to create a wrapper from. Values are passed through to the module. | `any` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_wrapper"></a> [wrapper](#output\_wrapper) | Map of outputs of a wrapper. |
<!-- END_TF_DOCS -->
