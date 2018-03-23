/*
 * AutoScaling for ECS Cluster (real resources is autoscaling group
 *
 * The below resources is optional.
 */

resource "aws_autoscaling_notification" "ok" {
  count         = "${var.autoscale_notification_ok_topic_arn != "" ? 1 : 0}"

  group_names   = ["${aws_autoscaling_group.app.name}"]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
  ]
  topic_arn     = "${var.autoscale_notification_ok_topic_arn}"
}

resource "aws_autoscaling_notification" "ng" {
  count         = "${var.autoscale_notification_ng_topic_arn != "" ? 1 : 0}"

  group_names   = ["${aws_autoscaling_group.app.name}"]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn     = "${var.autoscale_notification_ng_topic_arn}"
}

resource "aws_autoscaling_policy" "scale_out" {
  count                     = "${ length(keys(var.autoscale_thresholds)) != 0 ? 1 : 0 }"

  name                      = "${aws_ecs_cluster.main.name}-ECSCluster-ScaleOut"
  autoscaling_group_name    = "${aws_autoscaling_group.app.name}"
  scaling_adjustment        = "${var.scale_out_adjustment}"
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = "${var.autoscale_cooldown}"
}

resource "aws_autoscaling_policy" "scale_in" {
  count                     = "${ length(keys(var.autoscale_thresholds)) != 0 ? 1 : 0 }"

  name                      = "${aws_ecs_cluster.main.name}-ECSCluster-ScaleIn"
  autoscaling_group_name    = "${aws_autoscaling_group.app.name}"
  scaling_adjustment        = "${var.scale_in_adjustment}"
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = "${var.autoscale_cooldown}"
}

// CPU Utilization

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count               = "${ lookup(var.autoscale_thresholds, "cpu_utilization_high", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUUtilization-High"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-out pushed by cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.autoscale_thresholds["cpu_utilization_high"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.scale_out.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  count               = "${ lookup(var.autoscale_thresholds, "cpu_utilization_low", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUUtilization-Low"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-in pushed by cpu-utilization-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.autoscale_thresholds["cpu_utilization_low"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.scale_in.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]
}

// Memory Reservation

resource "aws_cloudwatch_metric_alarm" "memory_reservation_high" {
  count               = "${ lookup(var.autoscale_thresholds, "memory_reservation_high", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-MemoryReservation-High"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-out pushed by memory-reservation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.autoscale_thresholds["memory_reservation_high"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.scale_out.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "memory_reservation_low" {
  count               = "${ lookup(var.autoscale_thresholds, "memory_reservation_low", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-MemoryReservation-Low"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-in pushed by memory-reservation-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.autoscale_thresholds["memory_reservation_low"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.scale_in.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]
}

// CPU Reservation

resource "aws_cloudwatch_metric_alarm" "cpu_reservation_high" {
  count               = "${ lookup(var.autoscale_thresholds, "cpu_reservation_high", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUReservation-High"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-out pushed by cpu-reservation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.autoscale_thresholds["cpu_reservation_high"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.scale_out.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_reservation_low" {
  count               = "${ lookup(var.autoscale_thresholds, "cpu_reservation_low", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUReservation-Low"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-in pushed by cpu-reservation-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.autoscale_thresholds["cpu_reservation_low"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.scale_in.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]
}
