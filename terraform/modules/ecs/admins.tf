resource "aws_ecs_cluster" "admin" {
  name = "${var.name}-admin"
}

resource "aws_launch_configuration" "admin" {
  name_prefix = "${var.role}-${var.name}-admin-"
  security_groups = ["${var.admin_security_groups}"]
  image_id = "${data.aws_ami.ecs.id}"
  iam_instance_profile = "${aws_iam_instance_profile.admin.name}"
  instance_type = "${var.admin_instance_type}"
  ebs_optimized = true
  key_name = "${var.key_name}"

  user_data = "${template_file.admin_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "admin" {
  name = "${var.role}-${var.name}-admin"
  vpc_zone_identifier = ["${var.admin_subnets}"]
  launch_configuration = "${aws_launch_configuration.admin.name}"
  load_balancers = ["${aws_elb.ssh.id}"]
  health_check_grace_period = 300
  health_check_type = "EC2"
  min_size = 1
  max_size = 3
  desired_capacity = "${var.admin_desired_capacity}"

  tag {
    key = "Name"
    value = "${var.name}-admin"
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
    key = "EnvID"
    value = "${var.environment_id}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.environment}"
    propagate_at_launch = true
  }
  tag {
    key = "Owner"
    value = "${var.owner}"
    propagate_at_launch = true
  }
  tag {
    key = "Application Name"
    value = "ConcourseCI"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "admin_scaleup" {
  name                   = "${var.name}-admin-scaleup"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.admin.name}"
}

resource "aws_autoscaling_policy" "admin_scaledown" {
  name                   = "${var.name}-admin-scaledown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.admin.name}"
}

resource "aws_cloudwatch_metric_alarm" "admin_scaleup" {
    alarm_name = "${var.name}-admin-scaleup"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "AWS/ECS"
    period = "60"
    statistic = "Average"
    threshold = "50"
    dimensions {
        ClusterName = "${aws_ecs_cluster.admin.name}"
    }
    alarm_description = "Cluster memory reservation above 50%"
    alarm_actions = ["${aws_autoscaling_policy.admin_scaleup.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "admin_scaledown" {
    alarm_name = "${var.name}-admin-scaledown"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "10"
    metric_name = "MemoryReservation"
    namespace = "AWS/ECS"
    period = "60"
    statistic = "Average"
    threshold = "30"
    dimensions {
        ClusterName = "${aws_ecs_cluster.admin.name}"
    }
    alarm_description = "Cluster memory reservation below 30%"
    alarm_actions = ["${aws_autoscaling_policy.admin_scaledown.arn}"]
}
