variable "name" {
  description = "Name of ECS Cluster"
}

# Container Instance(s)

variable "ecs_instance_iam_policy_arns" {
  description = "IAM policy arns for container instance"
  type        = "list"
  default     = [
    # http://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
  ]
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an container instance in a VPC"
  default     = true
}

variable "key_name" {
  description = "Name of AWS key pair"
  type        = "string"
}

variable "ami_id" {
  description = "AWS machine image id"
  type        = "string"
}

variable "vpc_zone_identifier" {
  description = "AWS vpc zone identifier(s)"
  type        = "list"
}

variable "instance_type" {
  description = "AWS containers instance type"
  default     = "t2.small"
}

variable "security_groups" {
  description = "AWS security group id(s) for container instances launch configuration"
  type        = "list"
}

variable "user_data" {
  description = "AWS user_data of containers instances"
  type        = "string"
}

variable "asg_min_size" {
  description = "Min numbers of servers in AutoScaling Group"
  default     = "0"
}

variable "asg_max_size" {
  description = "Max numbers of servers in AutoScaling Group"
  default     = "2"
}

variable "asg_enabled_metrics" {
  description = "A list of metrics to collect in AutoScaling Group"
  type        = "list"
  default     = [
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
  ]
}

variable "asg_termination_policies" {
  description = "AutoScaling Group termination_policies"
  type        = "list"
  default     = ["OldestInstance"]
}

variable "asg_default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes"
  default     = 150
}

variable "asg_extra_tags" {
  description = "AWS EC2 Tag for AutoScaling Group (and attached instances)"
  type        = "list"
  default     = [/*
    # like: https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#interpolated-tags
    {
      key                 = "Name"
      name                = "Foo"
      propagate_at_launch = true
    },
    { ...
  */]
}

# Cloudwatch Log Group

variable "log_groups_expiration_days" {
  description = "Specifies the number of days you want to retain log events"
  default     = 30
}
