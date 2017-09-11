resource "aws_iam_role" "ecs_instance" {
  name                  = "${aws_ecs_cluster.main.name}-ecs-instance-role"
  force_detach_policies = true

  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  count      = "${length(var.iam_policy_arns)}"

  role       = "${aws_iam_role.ecs_instance.name}"
  policy_arn = "${element(var.iam_policy_arns, count.index)}"

  depends_on = ["aws_iam_role.ecs_instance"]
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name       = "${aws_ecs_cluster.main.name}-ecs-instance-profile"
  role       = "${aws_iam_role.ecs_instance.name}"

  depends_on = ["aws_iam_role.ecs_instance"]
}
