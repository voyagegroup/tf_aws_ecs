================================
aws ecs/cluster terraform module
================================

A terraform module to provides ecs cluster

* ECS Cluster
   * with AutoScaling Group
   * with Launch Configuration
   * with IAM Role & attached IAM Policy
   * with CloudWatch Log Group
* *[Optional] Autoscaling*

See more details about `Amazon ECS Clusters`_ in the official AWS docs.

.. _Amazon ECS Clusters: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_clusters.html#cluster_concepts

----

.. contents::
   :local:
   :depth: 2

Basic Usage
===========

* Input  variables: See `variables.tf <variables.tf>`_
* Output variables: See `outputs.tf <outputs.tf>`_

.. code:: hcl

   provider "aws" {
     # https://github.com/terraform-providers/terraform-provider-aws/releases
     version = "~> 1.0"
     region  = "${var.region}"
   }

   # Pre-require your resources declaration (as may be necessary)
   # The following related sources is out of scope on this module
   #resource "aws_key_pair"       "xxx" {}
   #resource "aws_subnet"         "xxx" {}
   #resource "aws_security_group" "xxx" {}
   #data     "aws_ami"            "xxx" {}

   module "ecs_cluster" {
     source                       = "git@github.com:voyagegroup/tf_aws_ecs//cluster"
     name                         = "ex-app-cluster"

     key_name                     = "${aws_key_pair.ex_app.key_name}"
     ami_id                       = "ami-04351e12"
     vpc_zone_identifier          = [
       "${aws_subnet.az_left.id}",
       "${aws_subnet.az_right.id}",
     ]
     security_groups              = ["${aws_security_group.ex_app.id}"]
     instance_type                = "c4.large"
     #ebs_optimized               = true
     user_data                    = "${ file('user_data.sh') }"

     asg_min_size                 = 0
     asg_max_size                 = 2
     #asg_default_cooldown        = 150
     #asg_enabled_metrics         = ["GroupDesiredCapacity"]
     #asg_termination_policies    = ["OldestInstance"]
     asg_extra_tags               = [
       {
         key                 = "Name"
         value               = "example-application"
         propagate_at_launch = true
       }
     ]

     log_group                    = "ex-app-cluster/ecs-agent"
     log_groups_expiration_days   = 14
   }


Advanced Usage
==============

As below U can create enhanced ecs-service using optional input-variables or others

.. contents::
   :local:


Enabled autoscaling
-------------------

.. code:: hcl

   module "ecs_cluster" {
     source = "git@github.com:voyagegroup/tf_aws_ecs//cluster"

     # ...

     autoscale_thresholds         = {
       memory_reservation_high = 75
       memory_reservation_low  = 40
       // cpu_util_high        =
       // cpu_util_low         =
       // cpu_reservation_high =
       // cpu_reservation_low  =
       // memory_util_high     =
       // memory_util_low      =
     }
     #scale_out_ok_actions        = []
     scale_out_more_alarm_actions = ["${aws_sns_topic.ex_alert.arn}"]
     #scale_in_ok_actions         = []
     #scale_in_more_alarm_actions = []
   }

See more details about `Scaling a Cluster`_ `What Is Auto Scaling?`_ in the official AWS docs.

.. _Scaling a Cluster:     http://docs.aws.amazon.com/AmazonECS/latest/developerguide/scale_cluster.html
.. _What Is Auto Scaling?: http://docs.aws.amazon.com/autoscaling/latest/userguide/WhatIsAutoScaling.html


Adding sns-notification for autoscaling-group scales
----------------------------------------------------

.. code:: hcl

   module "ecs_cluster" {
      # ...

      autoscale_notification_ok_topic_arn = "${aws_sns_topic.ex.arn}"
      autoscale_notification_ng_topic_arn = "${aws_sns_topic.ex_alert.arn}"
   }

See more details about `Getting SNS Notifications When Your Auto Scaling Group Scales`_ in the official AWS docs.

.. _Getting SNS Notifications When Your Auto Scaling Group Scales: http://docs.aws.amazon.com/autoscaling/latest/userguide/ASGettingNotifications.html
