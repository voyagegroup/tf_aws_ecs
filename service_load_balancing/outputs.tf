output "service_name" {
  value = var.name
}

output "log_group_name" {
  value = length(var.log_groups) > 0 ? aws_cloudwatch_log_group.app[0].name : ""
}

output "log_group_arn" {
  value = length(var.log_groups) > 0 ? aws_cloudwatch_log_group.app[0].arn : ""
}
