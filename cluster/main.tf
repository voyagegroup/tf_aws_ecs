resource "aws_ecs_cluster" "main" {
  name = "${var.name}"
}

resource "aws_cloudwatch_log_group" "ecs_agent" {
  name              = "${var.log_group}"
  retention_in_days = "${var.log_groups_expiration_days}"
}

resource "aws_autoscaling_group" "app" {
  name                 = "${aws_ecs_cluster.main.name}"
  enabled_metrics      = ["${var.asg_enabled_metrics}"]

  launch_configuration = "${aws_launch_configuration.app.name}"
  termination_policies = ["${var.asg_termination_policies}"]

  # NOTE: this module no handled desired capacity
  #desired_capacity     = "${var.asg_desired}"
  min_size             = "${var.asg_min_size}"
  max_size             = "${var.asg_max_size}"

  vpc_zone_identifier  = ["${var.vpc_zone_identifier}"]
  default_cooldown     = "${var.asg_default_cooldown}"

  tags = ["${var.asg_extra_tags}"]

  lifecycle {
    create_before_destroy = true
    # NOTE: changed automacally by autoscale policy
    ignore_changes        = ["desired_capacity"]
  }
}


resource "aws_launch_configuration" "app" {
  name_prefix                 = "${aws_ecs_cluster.main.name}-"
  security_groups             = ["${var.security_groups}"]
  key_name                    = "${var.key_name}"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  ebs_optimized               = "${var.ebs_optimized}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_instance.name}"
  user_data                   = "${var.user_data}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  enable_monitoring           = true

  # NOTE: Currently no-support to customizing block device(s)
  #       - OS specified image_id is not always using /dev/xvdcz as docker storage
  #       - As a workaround, creates the ami that it is customizing to the block device mappings
  #root_block_device {}
  #ebs_block_device  { device_name = "/dev/xvdcz" }

  lifecycle {
    create_before_destroy = true
  }
}
