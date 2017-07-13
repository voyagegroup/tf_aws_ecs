variable "name" {
  description = "Name of ECS Cluster"
}

# Cloudwatch Log Group

variable "cloudwatch_log_groups_expiration_days" {
  description = "Specifies the number of days you want to retain log events"
  default     = 30
}
