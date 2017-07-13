output "cluster_id" {
  value = "${aws_ecs_cluster.main.id}"
}

output "cloudwatch_log_group_arn" {
  value = "${aws_cloudwatch_log_group.ecs_agent.arn}"
}
