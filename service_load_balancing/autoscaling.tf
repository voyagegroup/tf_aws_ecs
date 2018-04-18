/*
 * AutoScaling for ECS Service
 *
 * The below resources is optional.
 */

resource "aws_appautoscaling_target" "main" {
  count              = "${ var.autoscale_iam_role_arn != "" ? 1 : 0 }"

  max_capacity       = "${var.autoscale_max_capacity}"
  min_capacity       = "${var.autoscale_min_capacity}"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main.name}"
  role_arn           = "${var.autoscale_iam_role_arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_out" {
  count              = "${ var.autoscale_iam_role_arn != "" ? 1 : 0 }"

  name               = "${aws_ecs_service.main.name}-ecs-service-scale-out"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "${var.autoscale_cooldown}"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = "${lookup(var.scale_out_step_adjustment, "metric_interval_lower_bound")}"
      scaling_adjustment          = "${lookup(var.scale_out_step_adjustment, "scaling_adjustment")}"
    }
  }

  depends_on         = ["aws_appautoscaling_target.main"]
}

resource "aws_appautoscaling_policy" "scale_in" {
  count              = "${ var.autoscale_iam_role_arn != "" ? 1 : 0 }"

  name               = "${aws_ecs_service.main.name}-ecs-service-scale-in"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "${var.autoscale_cooldown}"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = "${lookup(var.scale_in_step_adjustment, "metric_interval_upper_bound")}"
      scaling_adjustment          = "${lookup(var.scale_in_step_adjustment, "scaling_adjustment")}"
    }
  }

  depends_on         = ["aws_appautoscaling_target.main"]
}

// Memory Utilization

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = "${ lookup(var.scale_out_thresholds, "memory", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_service.main.name}-ECSService-MemoryUtilization-High"
  alarm_description   = "${aws_ecs_service.main.name} scale-out pushed by memory-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_out_evaluation_periods}"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_cooldown}"
  statistic           = "Average"
  threshold           = "${var.scale_out_thresholds["memory"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${aws_ecs_service.main.name}"
  }

  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_appautoscaling_policy.scale_out.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  count               = "${ lookup(var.scale_in_thresholds, "memory", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_service.main.name}-ECSService-MemoryUtilization-Low"
  alarm_description   = "scale-in pushed by memory-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_in_evaluation_periods}"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_cooldown}"
  statistic           = "Average"
  threshold           = "${var.scale_in_thresholds["memory"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${aws_ecs_service.main.name}"
  }

  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_appautoscaling_policy.scale_in.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]
}

// CPU Utilization

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = "${ lookup(var.scale_out_thresholds, "cpu", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_service.main.name}-ECSService-CPUUtilization-High"
  alarm_description   = "${aws_ecs_service.main.name} scale-out pushed by cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_out_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_cooldown}"
  statistic           = "Average"
  threshold           = "${var.scale_out_thresholds["cpu"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${aws_ecs_service.main.name}"
  }

  ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = [
    "${aws_appautoscaling_policy.scale_out.arn}",
    "${compact(var.scale_out_more_alarm_actions)}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = "${ lookup(var.scale_in_thresholds, "cpu", "") != "" ? 1 : 0 }"

  alarm_name          = "${aws_ecs_service.main.name}-ECSService-CPUUtilization-Low"
  alarm_description   = "${aws_ecs_service.main.name} scale-in pushed by cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.scale_in_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.autoscale_cooldown}"
  statistic           = "Average"
  threshold           = "${var.scale_in_thresholds["cpu"]}"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${aws_ecs_service.main.name}"
  }

  ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = [
    "${aws_appautoscaling_policy.scale_in.arn}",
    "${compact(var.scale_in_more_alarm_actions)}",
  ]
}
