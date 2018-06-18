resource "aws_cloudwatch_log_group" "app" {
  count             = "${ length(var.log_groups) }"

  name              = "${var.log_groups[count.index]}"
  retention_in_days = "${var.log_groups_expiration_days}"
  tags              = "${var.log_groups_tags}"
}
