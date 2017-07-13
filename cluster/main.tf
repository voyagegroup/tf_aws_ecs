resource "aws_ecs_cluster" "main" {
  name = "${var.name}"
}

# Cloudwatch Log Group

resource "aws_cloudwatch_log_group" "ecs_agent" {
  name              = "${aws_ecs_cluster.main.name}/ecs-agent"
  retention_in_days = "${var.cloudwatch_log_groups_expiration_days}"
}
