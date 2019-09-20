variable "name" {
  description = "Name of ECS Cluster"
}

# Container Instance(s)

variable "iam_path" {
  description = "IAM path for role & instance_profile"
  default     = "/"
}

variable "iam_policy_arns" {
  description = "IAM policy arns for container instance"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
  ]
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an container instance in a VPC"
  default     = true
}

variable "key_name" {
  description = "Name of AWS key pair"
  type        = string
}

variable "ami_id" {
  description = "AWS machine image id"
  type        = string
}

variable "vpc_zone_identifier" {
  description = "AWS vpc zone identifier(s)"
  type        = list(string)
}

variable "security_groups" {
  description = "AWS security group id(s) for container instances launch configuration"
  type        = list(string)
}

variable "instance_type" {
  description = "AWS containers instance type"
  default     = "t2.small"
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = true
}

variable "user_data" {
  description = "AWS user_data of containers instances"
  type        = string
}

variable "asg_min_size" {
  description = "Min numbers of servers in AutoScaling Group"
  default     = "0"
}

variable "asg_max_size" {
  description = "Max numbers of servers in AutoScaling Group"
  default     = "2"
}

variable "asg_default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes"
  default     = 150
}

variable "asg_enabled_metrics" {
  description = "A list of metrics to collect in AutoScaling Group"
  type        = list(string)
  default = [
  ]
  # http://docs.aws.amazon.com/autoscaling/latest/userguide/as-instance-monitoring.html#as-enable-group-metrics
  # Candidates is bellow as:
  /*
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
    */
}

variable "asg_termination_policies" {
  description = "AutoScaling Group termination_policies"
  type        = list(string)
  default     = ["OldestInstance"]
}

variable "asg_extra_tags" {
  description = "AWS EC2 Tag for AutoScaling Group (and attached instances)"
  type        = list
  default = [
  ]
  /*
    # like: https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#interpolated-tags
    {
      key                 = "Name"
      name                = "Foo"
      propagate_at_launch = true
    },
    { ...
  */
}

variable "root_volume_size" {
  description = "The size of the root volume in gigabytes"
  default     = 8
}

# AutoScaling

variable "autoscale_notification_ok_topic_arn" {
  description = "ARN of SNS Topic for notify to autoscaling:{EC2_INSTANCE_LAUNCH,autoscaling:EC2_INSTANCE_TERMINATE}"
  default     = "" // default as no-notify
}

variable "autoscale_notification_ng_topic_arn" {
  description = "ARN of SNS Topic for notify to autoscaling:{EC2_INSTANCE_LAUNCH_ERROR,autoscaling:EC2_INSTANCE_TERMINATE_ERROR}"
  default     = "" // default as no-notify
}

variable "autoscale_period" {
  description = "The period in seconds over which the specified applied for autoscaling"
  default     = 300
}

variable "autoscale_cooldown" {
  description = "The amount of time (seconds) after a scaling activity completes and before the next scaling activity can start"
  default     = 300
}

# AutoScaling > scale-out

variable "scale_out_thresholds" {
  description = "The values against which the specified statistic is compared"
  type        = map(string)
  default     = {}
  # Supporting thresholds as berow
  #cpu_util          = // e.g. 75
  #cpu_reservation   = // e.g. 75
  #memory_util       = // e.g. 75
  #memory_reservaion = // e.g. 75
}

variable "scale_out_ok_actions" {
  description = "For scale-out as same as ok actions for cloudwatch alarms"
  type        = list(string)
  default     = []
}

variable "scale_out_more_alarm_actions" {
  description = "For scale-out as same as alarm actions for cloudwatch alarms"
  type        = list(string)
  default     = []
}

variable "scale_out_evaluation_periods" {
  description = "The number of evaluation periods to scale out"
  default     = 1
}

variable "scale_out_adjustment" {
  description = "The number of instances by which to scale out"
  default     = 1
}

# AutoScaling > scale-in

variable "scale_in_thresholds" {
  description = "The values against which the specified statistic is compared for scale_in"
  type        = map(string)
  default     = {}
  # Supporting thresholds as berow
  #cpu_util           = // e.g.  5
  #cpu_reservation    = // e.g.  5
  #memory_util        = // e.g. 40
  #memory_reservation = // e.g. 40
}

variable "scale_in_evaluation_periods" {
  description = "The number of evaluation periods to scale in"
  default     = 2
}

variable "scale_in_adjustment" {
  description = "The number of instances by which to scale out"
  default     = -1
}

variable "scale_in_ok_actions" {
  description = "For scale-in as same as ok actions for cloudwatch alarms"
  type        = list(string)
  default     = []
}

variable "scale_in_more_alarm_actions" {
  description = "For scale-in as same as alarm actions for cloudwatch alarms"
  type        = list(string)
  default     = []
}

# Cloudwatch Log Group

variable "log_group" {
  description = "The name of cloudwatch log group"
  type        = string
}

variable "log_groups_expiration_days" {
  description = "Specifies the number of days you want to retain log events"
  default     = 30
}

variable "log_groups_tags" {
  description = "The tags of cloudwatch log group"
  type        = map(string)
  default     = {}
}
