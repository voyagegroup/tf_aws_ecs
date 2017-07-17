# aws ecs/service_load_balancing terraform module

A terraform module to provides ecs service balanced on application load balancer

## Usage

* Input variables:  See [variables.tf](variables.tf)
* Output variables: See [outputs.tf](outputs.tf)

* Out of scope
  * ALB
  * ALB Listener Rule
  * ALB Target Group

```hcl
module "ecs_service" {
  source                       = "git@github.com:voyagegroup/tf_aws_ecs//service_load_balancing"
  name                         = "ex-app-api-service"
  cluser_id                    = "${aws_ecs_cluster.ex_app.id}"
  cluster_name                 = "${aws_ecs_cluster.ex_app.name}"
  target_group_arn             = "${aws_alb_target_group.ex_app_api.arn}"

  container_name               = "ex-app-api"           // same as "name"          into container_defition
  container_port               = "80"                   // same as "containerPort" into container_defition
  container_log_group          = "ex-app-api/container" // same as "awslogs-group" into container_defition
  container_definitions        = <<TASK_DEFITION
[
  {
    "name":      "ex-app-api",
    "essential": true,
    "image":     "${var.YOUR_AWS_ACCOUNT_ID}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/ex-app-api:latest",
    "cpu":       512,
    "memory":    1024,
    "portMappings": [
     {
        "hostPort": 0,
        "containerPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group":  "ex-app-api-service/container",
        "awslogs-region": "${var.AWS_REGION}"
      }
    }
  }
]
TASK_DEFITION

  #
  # [Option] AutoScaling
  #
  autoscale_min_capacity       = 2
  autoscale_max_capacity       = 8
  autoscale_thresholds         = {
    memory_high = 75
    memory_low  = 40
  }
  scale_out_more_alarm_actions = ["${aws_sns_topic.ex_alert.arn}"]
  scale_out_step_adjustment    = {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 1
  }
  scale_in_step_adjustment     = {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }
}
```
