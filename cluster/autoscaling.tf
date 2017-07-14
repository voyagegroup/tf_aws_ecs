/*
 * AutoScaling for ECS Cluster (real resources is autoscaling group
 */

# CPU Reservation

resource "aws_autoscaling_policy" "scale_out_cpu_high" {
  count                  = "${ lookup(var.autoscale_thresholds, "cpu_reservation_high") != "" ? 1 : 0 }"

  name                   = "${aws_ecs_cluster.main.name}-ScaleOut-CPUReservation-High"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  scaling_adjustment     = "${var.scale_out_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_reservation_high" {
  count               = "${ lookup(var.autoscale_thresholds, "cpu_reservation_high") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUReservation-High"
  alarm_description   = "scale-out pushed by cpu-reservation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_cooldown}"
  statistic           = "Average"
  threshold           = "${var.autoscale_thresholds["cpu_reservation_high"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.scale_out_cpu_high.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]
}

resource "aws_autoscaling_policy" "scale_in_cpu_low" {
  count                  = "${ lookup(var.autoscale_thresholds, "cpu_reservation_low") != "" ? 1 : 0 }"

  name                   = "${aws_ecs_cluster.main.name}-ScaleOut-CPUReservation-Low"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  scaling_adjustment     = "${var.scale_in_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.autoscale_cooldown}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_reservation_low" {
  count               = "${ lookup(var.autoscale_thresholds, "cpu_reservation_low") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_cluster.main.name}-ECSCluster-CPUReservation-Low"
  alarm_description   = "scale-in pushed by cpu-reservation-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_cooldown}"
  statistic           = "Average"
  threshold           = "${var.autoscale_thresholds["cpu_reservation_low"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_autoscaling_policy.scale_in_cpu_low.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]
}
