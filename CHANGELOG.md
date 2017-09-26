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
