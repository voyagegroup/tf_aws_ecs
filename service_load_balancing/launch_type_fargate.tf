// NOTE: var.launch_type = "FARGATE" if you want use following

resource "aws_ecs_cluster" "fargate" {
  count = var.launch_type == "FARGATE" ? 1 : 0
  name  = var.cluster_name
}

resource "aws_ecs_service" "fargate" {
  count = var.launch_type == "FARGATE" ? 1 : 0

  name            = var.name
  cluster         = aws_ecs_cluster.fargate[0].id
  launch_type     = var.launch_type
  task_definition = aws_ecs_task_definition.fargate[0].arn

  # As below is can be running in a service during a deployment
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
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

resource "aws_ecs_task_definition" "fargate" {
  count = var.launch_type == "FARGATE" ? 1 : 0

  family                   = var.container_family
  container_definitions    = var.container_definitions
  network_mode             = var.network_mode
  requires_compatibilities = [var.launch_type]
  execution_role_arn       = var.execution_role_arn != "" ? var.execution_role_arn : data.aws_iam_role.execution[0].arn
  task_role_arn            = var.task_role_arn != "" ? var.task_role_arn : null
}
