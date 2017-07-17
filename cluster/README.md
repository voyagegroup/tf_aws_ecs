# aws ecs/cluster terraform module

A terraform module to provides ecs cluster

## Usage

* Input variables:  See [variables.tf](variables.tf)
* Output variables: See [outputs.tf](outputs.tf)

```hcl
module "ecs_cluster" {
  source                       = "git@github.com:voyagegroup/tf_aws_ecs//cluster"
  name                         = "ex-app-cluster"

  #
  # CloudWatch Logs
  #
  log_group                    = "ex-app-cluster/ecs-agent"
  log_groups_expiration_days   = 14

  #
  # Container Instance
  #
  key_name                     = "${aws_key_pair.ex_app.key_name}"
  ami_id                       = "ami-04351e12"
  vpc_zone_identifier          = [
    "${aws_subnet.az_left.id}",
    "${aws_subnet.az_right.id}",
  ]
  security_groups              = ["${aws_security_group.ex_app.id}"]
  instance_type                = "c4.large"
  user_data                    = "${ file('user_data.sh') }"

  #
  # AutoScaling Group
  #
  asg_min_size                 = 0
  asg_max_size                 = 2
  asg_enabled_metrics          = [
    "GroupDesiredCapacity",
    "GroupStandbyInstances",
  ]
  asg_extra_tags               = [
    {
      key                 = "Name"
      name                = "example-application"
      propagate_at_launch = true
    }
  ]

  #
  # [Option] AutoScaling
  #
  autoscale_thresholds         = {
    memory_reservation_high = 75
    memory_reservation_low  = 40
  }
  scale_out_more_alarm_actions = ["${aws_sns_topic.ex_alert.arn}"]
}
```
