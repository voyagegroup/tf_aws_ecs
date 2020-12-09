// NOTE: var.launch_type = "EC2" if you want use following

resource "aws_ecs_service" "main" {
  count = var.launch_type == "EC2" ? 1 : 0

  name            = var.name
  cluster         = var.cluster_id
  launch_type     = var.launch_type
  task_definition = aws_ecs_task_definition.container[0].arn

  # As below is can be running in a service during a deployment
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  ordered_placement_strategy {
    type  = var.placement_strategy_type
    field = var.placement_strategy_field
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    # INFO: In the future, we support that U can customize
    #       https://github.com/hashicorp/terraform/issues/3116
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }
}

resource "aws_ecs_task_definition" "container" {
  count = var.launch_type == "EC2" ? 1 : 0

  family                = var.container_family
  container_definitions = var.container_definitions
  execution_role_arn    = var.execution_role_arn != "" ? var.execution_role_arn : data.aws_iam_role.execution[0].arn
  task_role_arn         = var.task_role_arn != "" ? var.task_role_arn : null
  # The following comment-out is no-support yet for BC-BREAK
  #network_mode            = "${var.network_mode}"
  #requires_compatibilities = ["${var.launch_type}"]
}
