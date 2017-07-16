variable "name" {
  description = "Name of ECS Service"
}

variable "cluster_name" {
  description = "Name of ECS Cluster"
}

variable "iam_assume_role_policy" {
  description = "AWS ECS Service Assume Role Policy at IAM Role"
  default     = <<EOT
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOT
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
  description = "AWS containers (family) name"
}

variable "container_port" {
  description = "AWS containers port"
}

variable "container_definitions" {
  description = "AWS ECS Task definitions"
  type        = "string"
}

variable "container_log_group" {
  description = "The Name of CloudWatch Log Group for ECS Task (Container)"
  default     = "" // It it is empty, no creattion cloudwatch_log_group
}

variable "container_log_groups_expiration_days" {
  description = "Specifies the number of days you want to retain log events"
  default     = 30
}
