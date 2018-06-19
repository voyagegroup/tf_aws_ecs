output "service_name" {
  value = "${var.name}"
}

output "log_group_name" {
  value = "${aws_cloudwatch_log_group.app.0.name}"
}

output "log_group_arn" {
  value = "${aws_cloudwatch_log_group.app.0.arn}"
}
