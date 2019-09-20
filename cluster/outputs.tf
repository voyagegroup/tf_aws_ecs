output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.ecs_agent.name
}

output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.ecs_agent.arn
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.app.name
}
