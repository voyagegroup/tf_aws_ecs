// NOTE: var.launch_type = "EC2" if you want use following

resource "aws_ecs_service" "main" {
  count = var.launch_type == "EC2" ? 1 : 0

  name            = var.name
  cluster         = var.cluster_id
  launch_type     = var.launch_type
  task_definition = aws_ecs_task_definition.container[0].arn
  iam_role        = var.task_role_arn == "" ? aws_iam_role.ecs_service[0].arn : var.task_role_arn

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
  # The following comment-out is no-support yet for BC-BREAK
  #network_mode            = "${var.network_mode}"
  #requires_compatibilities = ["${var.launch_type}"]
}

resource "aws_iam_role" "ecs_service" {
  count = var.launch_type == "EC2" && var.task_role_arn == "" ? 1 : 0

  name                  = "${var.name}-ecs-service-role"
  path                  = var.iam_path
  force_detach_policies = true
  assume_role_policy    = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service" {
  count = var.launch_type == "EC2" && var.task_role_arn == "" ? 1 : 0

  name   = "${var.name}-ecs-service-policy"
  role   = aws_iam_role.ecs_service[0].name
  policy = var.iam_role_inline_policy
}
