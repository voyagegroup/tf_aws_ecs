resource "aws_ecs_cluster" "main" {
  name = var.name
}

resource "aws_cloudwatch_log_group" "ecs_agent" {
  name              = var.log_group
  retention_in_days = var.log_groups_expiration_days
  tags              = var.log_groups_tags
}

resource "aws_autoscaling_group" "app" {
  name            = aws_ecs_cluster.main.name
  enabled_metrics = var.asg_enabled_metrics

  launch_configuration = var.use_launch_template ? null : aws_launch_configuration.app.name
  launch_template {
    id      = var.use_launch_template ? aws_launch_template.app.id : null
    version = var.use_launch_template ? aws_launch_template.app.latest_version : null
  }

  protect_from_scale_in = var.asg_protect_from_scale_in
  termination_policies  = var.asg_termination_policies

  # NOTE: this module no handled desired capacity
  #desired_capacity     = "${var.asg_desired}"
  min_size = var.asg_min_size
  max_size = var.asg_max_size

  vpc_zone_identifier = var.vpc_zone_identifier
  default_cooldown    = var.asg_default_cooldown

  dynamic "tag" {
    for_each = toset(var.asg_extra_tags)
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  lifecycle {
    create_before_destroy = true
    # NOTE: changed automacally by autoscale policy
    ignore_changes = [desired_capacity]
  }
}

# NOTE: launch_configuration is deprecated
resource "aws_launch_configuration" "app" {
  name_prefix                 = "${aws_ecs_cluster.main.name}-"
  security_groups             = var.security_groups
  key_name                    = var.key_name
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance.name
  user_data                   = var.user_data
  associate_public_ip_address = var.associate_public_ip_address
  enable_monitoring           = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  # NOTE: Currently no-support to customizing block device(s)
  #   - OS specified image_id is not always using /dev/xvdcz as docker storage
  #   - As a workaround, creates the ami that it is customizing to the block device mappings
  #
  # DOCS: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-ami-storage-config.html
  #ebs_block_device  { device_name = "/dev/xvdcz" }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []
    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, null)
      http_tokens                 = try(metadata_options.value.http_tokens, null)
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${aws_ecs_cluster.main.name}-"
  key_name      = var.key_name
  image_id      = var.ami_id
  instance_type = var.instance_type
  ebs_optimized = var.ebs_optimized
  user_data     = var.user_data

  block_device_mappings {
    device_name = var.root_device_name
    ebs {
      volume_type           = "gp3"
      volume_size           = var.root_volume_size
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  network_interfaces {
    security_groups             = var.security_groups
    associate_public_ip_address = var.associate_public_ip_address
  }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []
    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, null)
      http_tokens                 = try(metadata_options.value.http_tokens, null)
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, null)
      http_protocol_ipv6          = try(metadata_options.value.http_protocol_ipv6, null)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
    }
  }

  monitoring {
    enabled = true
  }
}
