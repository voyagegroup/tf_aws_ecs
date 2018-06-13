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

// Memory Utilization

resource "aws_autoscaling_policy" "memory_util_high" {
  count                  = "${ lookup(var.scale_out_thresholds, "memory_util", "") != "" ? 1 : 0 }"

  name                   = "${aws_ecs_cluster.main.name}-scale_out-memory_util"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  scaling_adjustment     = "${var.scale_out_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "memory_util_high" {
  count               = "${ lookup(var.scale_out_thresholds, "memory_util", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-MemoryUtilization-High"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-out pushed by memory-util"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_out_evaluation_periods}"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.scale_out_thresholds["memory_util"]}"
  treat_missing_data  = "notBreaching"
  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.memory_util_high.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

resource "aws_autoscaling_policy" "memory_util_low" {
  count                  = "${ lookup(var.scale_in_thresholds, "memory_util", "") != "" ? 1 : 0 }"

  name                   = "${aws_ecs_cluster.main.name}-scale_in-memory_util"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  scaling_adjustment     = "${var.scale_in_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "memory_util_low" {
  count               = "${ lookup(var.scale_in_thresholds, "memory_util", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-MemoryUtilization-Low"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-in pushed by memory-util"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_in_evaluation_periods}"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.scale_in_thresholds["memory_util"]}"
  treat_missing_data  = "notBreaching"
  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.memory_util_low.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

// CPU Utilization

resource "aws_autoscaling_policy" "cpu_util_high" {
  count                  = "${ lookup(var.scale_out_thresholds, "cpu_util", "") != "" ? 1 : 0 }"

  name                   = "${aws_ecs_cluster.main.name}-scale_out-cpu_util"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  scaling_adjustment     = "${var.scale_out_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_util_high" {
  count               = "${ lookup(var.scale_out_thresholds, "cpu_util", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUUtilization-High"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-out pushed by cpu-util"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_out_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.scale_out_thresholds["cpu_util"]}"
  treat_missing_data  = "notBreaching"
  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.cpu_util_high.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

resource "aws_autoscaling_policy" "cpu_util_low" {
  count                  = "${ lookup(var.scale_in_thresholds, "cpu_util", "") != "" ? 1 : 0 }"

  name                   = "${aws_ecs_cluster.main.name}-scale_in-cpu_util"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  scaling_adjustment     = "${var.scale_in_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_util_low" {
  count               = "${ lookup(var.scale_in_thresholds, "cpu_util", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUUtilization-Low"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-in pushed by cpu-util"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_in_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.scale_in_thresholds["cpu_util"]}"
  treat_missing_data  = "notBreaching"
  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.cpu_util_low.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

// Memory Reservation

resource "aws_autoscaling_policy" "memory_reservation_high" {
  count               = "${ lookup(var.scale_out_thresholds, "memory_reservation", "") != "" ? 1 : 0 }"

  name                      = "${aws_ecs_cluster.main.name}-scale_out-memory_reservation"
  autoscaling_group_name    = "${aws_autoscaling_group.app.name}"
  scaling_adjustment        = "${var.scale_out_adjustment}"
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "memory_reservation_high" {
  count               = "${ lookup(var.scale_out_thresholds, "memory_reservation", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-MemoryReservation-High"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-out pushed by memory-reservation"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_out_evaluation_periods}"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.scale_out_thresholds["memory_reservation"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.memory_reservation_high.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]
}

resource "aws_autoscaling_policy" "memory_reservation_low" {
  count                  = "${ lookup(var.scale_in_thresholds, "memory_reservation", "") != "" ? 1 : 0 }"

  name                   = "${aws_ecs_cluster.main.name}-scale_in-memory_reservation"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  scaling_adjustment     = "${var.scale_in_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "memory_reservation_low" {
  count               = "${ lookup(var.scale_in_thresholds, "memory_reservation", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-MemoryReservation-Low"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-in pushed by memory-reservation"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_in_evaluation_periods}"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.scale_in_thresholds["memory_reservation"]}"
  treat_missing_data  = "notBreaching"
  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.memory_reservation_low.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

// CPU Reservation

resource "aws_autoscaling_policy" "cpu_reservation_high" {
  count                  = "${ lookup(var.scale_out_thresholds, "cpu_reservation", "") != "" ? 1 : 0 }"

  name                   = "${aws_ecs_cluster.main.name}-scale_out-cpu_reservation"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  scaling_adjustment     = "${var.scale_out_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_reservation_high" {
  count               = "${ lookup(var.scale_out_thresholds, "cpu_reservation", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUReservation-High"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-out pushed by cpu-reservation"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_out_evaluation_periods}"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.scale_out_thresholds["cpu_reservation"]}"
  treat_missing_data  = "notBreaching"
  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.cpu_reservation_high.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

resource "aws_autoscaling_policy" "cpu_reservation_low" {
  count                  = "${ lookup(var.scale_in_thresholds, "cpu_reservation", "") != "" ? 1 : 0 }"

  name                   = "${aws_ecs_cluster.main.name}-scale_in-cpu_reservation"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  scaling_adjustment     = "${var.scale_in_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_reservation_low" {
  count               = "${ lookup(var.scale_in_thresholds, "cpu_reservation", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUReservation-Low"
  alarm_description   = "${aws_ecs_cluster.main.name} scale-in pushed by cpu-reservation"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_in_evaluation_periods}"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_period}"
  statistic           = "Average"
  threshold           = "${var.scale_in_thresholds["cpu_reservation"]}"
  treat_missing_data  = "notBreaching"
  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.cpu_reservation_low.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}
