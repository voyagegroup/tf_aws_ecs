# aws ecs/cluster terraform module

A terraform module to provides ecs cluster

## Usage

Input variables: See [variables.tf](variables.tf)

Output variables: See [outputs.tf](outputs.tf)

```hcl
module "ecs_cluster" {
  source = "github.com/voyagegroup/tf_aws_ecs/cluster"
  name   = "vg-app"
}
```
