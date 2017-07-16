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
  source                       = "github.com/voyagegroup/tf_aws_ecs/service_load_balancing"
  name                         = "ex-app-api-service"
  cluster_name                 = "${aws_ecs_cluster.ex_app.name}"
  target_group_arn             = "${aws_alb_target_group.ex_app_api.arn}"

  container_name               = "ex-app-api"           // same as "name"          into container_defition
  container_port               = "80"                   // same as "containerPort" into container_defition
  container_log_group          = "ex-app-api/container" // same as "awslogs-group" into container_defition
  container_definition         = <<TASK_DEFITION
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
}
```
