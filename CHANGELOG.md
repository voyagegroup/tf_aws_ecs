## 0.3.0 (Unreleased)

**BC BREAKS:** cluster & service_load_balancing module: variable `autoscale_thresholds` splits
to `scale_out_thresholds` / `scale_in_thresholds`

Code migrations example:

- cluster:

```hcl
# Before:
module "ex_ecs_cluster" {
  source                    = "git@github.com:voyagegroup/tf_aws_ecs?ref=v0.2.2//cluster"
  # ...
  autoscale_thresholds      = {
    cpu_reservation_high    = 70
    cpu_reservation_low     = 10
    memory_reservation_high = 80
    memory_reservation_low  = 20
  }
}

# After:
module "ex_ecs_cluster" {
  source               = "git@github.com:voyagegroup/tf_aws_ecs?ref=v0.3.0//cluster"
  # ...
  scale_out_thresholds = {
    cpu_util           = 70
    cpu_reservation    = 70
    memory_util        = 80
    memory_reservation = 80
  }
  scale_in_thresholds  = {
    cpu_util           = 70
    cpu_reservation    = 10
    memory_util        = 20
    memory_reservation = 20
  }
}
```

- service_load_balancing:

```hcl
# Before:
module "ex_ecs_service" {
  source               = "git@github.com:voyagegroup/tf_aws_ecs?ref=v0.2.2//service_load_balancing"
  # ...
  autoscale_thresholds = {
    cpu_high    = 60
    cpu_low     =  8
    memory_high = 75
    memory_low  = 10
  }
}

# After:
module "ex_ecs_service" {
  source               = "git@github.com:voyagegroup/tf_aws_ecs?ref=v0.3.0//service_load_balancing"
  # ...
  scale_out_thresholds = {
    cpu    = 60
    memory = 75
  }
  scale_in_thresholds  = {
    cpu    =  8
    memory = 10
  }
}
```

* cluster: Parameterized to evaluation_periods
  * `scale_out_evaluation_periods` (default: 1)
  * `scale_in_evaluation_periods` (default: 2)
* service_load_balancing: Parameterized to evaluation_periods
  * `scale_out_evaluation_periods` (default: 1)
  * `scale_in_evaluation_periods` (default: 2)

## 0.2.2 (Mar 26, 2018)

* cluster: support more autoscaling thresholdsthreads from #12
  * cpu_util_high
  * cpu_util_low
  * memory_util_high
  * memory_util_low

## 0.2.1 (Mar 14, 2018)

* cluster: support specify iam path for role and instance_profile (default: '/')
  * new variable: `iam_path`

## 0.2.0 (Mar 7, 2018)

* **BC BREAKS:** service_load_balancing: #11 No creating aws_iam_role for application autoscaling
  * new variable `autoscale_iam_role_arn` that should specify if enabled autoscaling
  * related: https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html

## 0.1.2 (Dec 15, 2017)

* service_load_balancing: #10 update iam role policy for appautoscaling

## 0.1.1 (Dec 15, 2017)

* service_load_balancing: #9 update iam role policy for appautoscaling
  * **this proposal includes bugs**, fixed on v0.1.2

## 0.1.0 (Oct 16, 2017)

* Support only terraform-provider-aws >= 1.0.0
* service_load_balancing: Remove unused variables
  * `scale_in_step_adjustment.metric_interval_upper_bound`
  * `scale_out_step_adjustment.metric_interval_lower_bound`

## 0.0.5 (Oct 12, 2017)

* service_load_balancing: ignore task_definition updating into aws_ecs_service
  * for cooperating with the ecs deployment process
  * related [#1](https://github.com/voyagegroup/tf_aws_ecs/issues/1)

## 0.0.4 (Sep 28, 2017)

* **BC BREAKS:** service_load_balancing: #6 split names (container, container family)
  * new variable: `container_family` using task definitions

## 0.0.3 (Sep 26, 2017)

* **BC BREAKS:** service_load_balancing: variable changed name, and type. log_group -> log_groups

## 0.0.2 (Sep 11, 2017)

* **BC BREAKS:** tf_aws_ecs require terraform >= v0.10
* cluster: when destroy, aws_iam_role prepare detaching policies
* service_load_balancing: when destroy, aws_iam_role prepare detaching policies

## 0.0.1 (Aug 1, 2017)

FEATURES:

* **New Module:** cluster (ECS Cluster)
* **New Module:** service_load_balancing (ECS Service for ServiceLoadBalancing)

* cluster: Support AutoScaling
* cluster: Support AutoScaling notification ([#3](https://github.com/voyagegroup/tf_aws_ecs/pull/3))
* service_load_balancing: Support AutoScaling
