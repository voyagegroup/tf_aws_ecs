variable "name" {
  description = "Name of ECS Service"
}

variable "cluster_id" {
  description = "ID (ARN) of ECS Cluster"
}

variable "cluster_name" {
  description = "Name of ECS Cluster using for autoscaling"
}

variable "iam_path" {
  description = "The Path of IAM Role(s)"
  default     = "/"
}

variable "iam_role_inline_policy" {
  description = "AWS ECS Service Policy at IAM Role"
  default     = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

variable "placement_strategy_type" {
  description = "The type of placement strategy"
  default     = "spread" // or binpack (this module cannot specify "random"
}

variable "placement_strategy_field" {
  description = "The field of placement strategy valid values that U select type"
  default     = "instanceId"
}

variable "desired_count" {
  description = "The number of instances of the task definition"
  default     = 0
}

variable "deployment_maximum_percent" {
  description = "The upper limit of the number of running tasks that can be running in a service during a deployment"
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit of the number of running tasks that must remain running and healthy in a service during a deployment"
  default     = 100
}

# INFO: In the future, we support that U can customize to ignore_changes in life_cycle block.
#       https://github.com/hashicorp/terraform/issues/3116
#
#variable "life_cycle_ignore_changes" {
#  description = "The list of ignored through changes for resource of ECS Service"
#  type        = "list"
#  default     = [
#    "desired_count",
#  ]
#}

# Application Load Balancer

variable "target_group_arn" {
  description = "The ARN of the ALB target group to associate with the service"
}

# Container

variable "container_name" {
  description = "AWS containers name as related load_balancer"
}

variable "container_port" {
  description = "AWS containers port"
}

variable "container_family" {
  description = "AWS containers family name"
  type        = "string"
}

variable "container_definitions" {
  description = "AWS ECS Task definitions"
  type        = "string"
}

variable "log_groups" {
  description = "The List of CloudWatch Log Group Name for ECS Task (Container)"
  type        = "list"
  default     = []
}

variable "log_groups_expiration_days" {
  description = "Specifies the number of days you want to retain log events"
  default     = 30
}

variable "log_groups_tags" {
  description = "The tags of cloudwatch log group"
  type        = "map"
  default     = {}
}

# AutoScaling

variable "autoscale_iam_role_arn" {
  description = "Specifies the IAM Role for ecs appautoscaling"
  default     = "" // not creates if empty
}

variable "autoscale_max_capacity" {
  description = "The max capacity of the scalable target"
  default     = 1
}

variable "autoscale_min_capacity" {
  description = "The min capacity of the scalable target"
  default     = 1
}

variable "autoscale_cooldown" {
  description = "The cooldown / period for watching scale (seconds)"
  default     = 300
}

# AutoScaling > scale-out

variable "scale_out_thresholds" {
  description = "The values against which the specified statistic is compared for scale_out"
  type        = "map"
  # No apply if empty
  default     = {
    # Supporting thresholds as berow
    #cpu    = // e.g. 75
    #memory = // e.g. 75
  }
}

variable "scale_out_step_adjustment" {
  description = "The attributes of step scaling policy"
  type        = "map"
  default     = {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 1
  }
}

variable "scale_out_evaluation_periods" {
  description = "The number of evaluation periods to scale out"
  default     = 1
}

variable "scale_out_ok_actions" {
  description = "For scale-out as same as ok actions for cloudwatch alarms"
  type        = "list"
  default     = []
}

variable "scale_out_more_alarm_actions" {
  description = "For scale-out as same as alarm actions for cloudwatch alarms"
  type        = "list"
  default     = []
}

# AutoScaling > scale-in

variable "scale_in_ok_actions" {
  description = "For scale-in as same as ok actions for cloudwatch alarms"
  type        = "list"
  default     = []
}

variable "scale_in_more_alarm_actions" {
  description = "For scale-in as same as alarm actions for cloudwatch alarms"
  type        = "list"
  default     = []
}

variable "scale_in_evaluation_periods" {
  description = "The number of evaluation periods to scale in"
  default     = 2
}

variable "scale_in_thresholds" {
  description = "The values against which the specified statistic is compared for scale_in"
  type        = "map"
  # No apply if empty
  default     = {
    # Supporting thresholds as berow
    #cpu    = // e.g.  5
    #memory = // e.g. 40
  }
}

variable "scale_in_step_adjustment" {
  description = "The attributes of step scaling policy"
  type        = "map"
  default     = {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }
}
