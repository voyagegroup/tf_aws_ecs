data "aws_ecs_cluster" "cluster" {
  cluster_name = "${var.cluster_name}"
}

resource "aws_ecs_task_definition" "container" {
  family                = "${var.container_name}"
  container_definitions = "${var.container_definitions}"
}

resource "aws_ecs_service" "main" {
  name            = "${var.name}"
  cluster         = "${data.aws_ecs_cluster.cluster.arn}"
  task_definition = "${aws_ecs_task_definition.container.arn}"
  iam_role        = "${aws_iam_role.ecs_service.arn}"

  # As below is can be running in a service during a deployment
  desired_count                      = "${var.desired_count}"
  deployment_maximum_percent         = "${var.deployment_maximum_percent}"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"

  placement_strategy {
    type  = "${var.placement_strategy_type}"
    field = "${var.placement_strategy_field}"
  }

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }

  lifecycle {
    ignore_changes = ["${var.life_cycle_ignore_changes}"]
  }

  depends_on = ["aws_iam_role_policy.ecs_service"]
}

resource "aws_iam_role" "ecs_service" {
  name               = "${var.name}-ecs-service-role"
  path               = "${var.iam_path}"
  assume_role_policy = "${var.iam_assume_role_policy}"
}

resource "aws_iam_role_policy" "ecs_service" {
  name   = "${var.name}-ecs-service-policy"
  role   = "${aws_iam_role.ecs_service.name}"
  policy = "${var.iam_role_inline_policy}"
}

resource "aws_cloudwatch_log_group" "app" {
  count             = "${ var.container_log_group != "" ? 1 : 0 }"

  name              = "${var.container_log_group}"
  retention_in_days = "${var.container_log_groups_expiration_days}"
}
