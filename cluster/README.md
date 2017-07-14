# aws ecs/cluster terraform module

A terraform module to provides ecs cluster

## Usage

* Input variables:  See [variables.tf](variables.tf)
* Output variables: See [outputs.tf](outputs.tf)

```hcl
module "ecs_cluster" {
  source                     = "github.com/voyagegroup/tf_aws_ecs/cluster"
  name                       = "vg-app"

  key_name                   = "${aws_key_pair.vg_app.key_name}"
  ami_id                     = "ami-04351e12"
  vpc_zone_identifier        = [
    ${aws_subnet.az_left.id},
    ${aws_subnet.az_right.id},
  ]
  security_groups            = ["${aws_security_group.vg_app.id}"]
  instance_type              = "c4.large"
  user_data                  = "${ file('user_data.sh') }"

  asg_min_size               = 0
  asg_max_size               = 2
  asg_enabled_metrics        = [
    "GroupDesiredCapacity",
    "GroupStandbyInstances",
  ]
  asg_extra_tags             = [
    {
      key                 = "Name"
      name                = "vg-app"
      propagate_at_launch = true
    }
  ]

  log_groups_expiration_days = 14
}
```
