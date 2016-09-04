resource "aws_ecs_cluster" "worker" {
  name = "${var.name}-worker"
}

resource "aws_launch_configuration" "worker" {
  name_prefix = "${var.role}-${var.name}-worker-"
  security_groups = ["${var.worker_security_groups}"]
  image_id = "${data.aws_ami.ecs.id}"
  iam_instance_profile = "${aws_iam_instance_profile.worker.name}"
  instance_type = "${var.worker_instance_type}"
  ebs_optimized = true
  key_name = "${var.key_name}"

  user_data = "${template_file.worker_user_data.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "gp2"
    volume_size = 22
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker" {
  name = "${var.role}-${var.name}-worker"
  vpc_zone_identifier = ["${var.worker_subnets}"]
  launch_configuration = "${aws_launch_configuration.worker.name}"
  health_check_grace_period = 300
  health_check_type = "EC2"
  min_size = 1
  max_size = 10
  desired_capacity = "${var.worker_desired_capacity}"

  tag {
    key = "Name"
    value = "${var.name}-worker"
    propagate_at_launch = true
  }
  tag {
    key = "Project"
    value = "${var.name}"
    propagate_at_launch = true
  }
  tag {
    key = "Team"
    value = "${var.team}"
    propagate_at_launch = true
  }
  tag {
    key = "Role"
    value = "${var.role}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.environment_id}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "worker_scaleup" {
  name                   = "${var.name}-worker-scaleup"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.worker.name}"
}

resource "aws_autoscaling_policy" "worker_scaledown" {
  name                   = "${var.name}-worker-scaledown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.worker.name}"
}

resource "aws_cloudwatch_metric_alarm" "worker_scaleup" {
    alarm_name = "${var.name}-worker-scaleup"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "AWS/ECS"
    period = "60"
    statistic = "Average"
    threshold = "50"
    dimensions {
        ClusterName = "${aws_ecs_cluster.worker.name}"
    }
    alarm_description = "Cluster memory utilization above 50%"
    alarm_actions = ["${aws_autoscaling_policy.worker_scaleup.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "worker_scaledown" {
    alarm_name = "${var.name}-worker-scaledown"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "10"
    metric_name = "MemoryUtilization"
    namespace = "AWS/ECS"
    period = "60"
    statistic = "Average"
    threshold = "30"
    dimensions {
        ClusterName = "${aws_ecs_cluster.worker.name}"
    }
    alarm_description = "Cluster memory utilization below 30%"
    alarm_actions = ["${aws_autoscaling_policy.worker_scaledown.arn}"]
}

