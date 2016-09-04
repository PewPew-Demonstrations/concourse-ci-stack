resource "aws_iam_role" "ecsInstance" {
  name = "${var.team}-${var.role}-${var.name}-ecsInstance"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "admin" {
  name = "${var.team}-${var.role}-${var.name}-adminECSInstance"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "worker" {
  name = "${var.team}-${var.role}-${var.name}-workerECSInstance"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "cloudwatch_logs" {
  name = "ECSCloudWatchLogs-${var.environment_id}"
  path = "${lower(format("/%s/%s/", var.team, var.name))}"
  description = "Access to CloudWatch logs API"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:PutMetricData",
        "ec2:DescribeTags",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudwatch_metrics" {
  name = "ECSCloudWatchMetrics-${var.environment_id}"
  path = "${lower(format("/%s/%s/", var.team, var.name))}"
  description = "Access to CloudWatch metrics API"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs" {
  name = "ECS-${var.environment_id}"
  path = "${lower(format("/%s/%s/", var.team, var.name))}"
  description = "ELB update access"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecr" {
  name = "ECR-${var.environment_id}"
  path = "${lower(format("/%s/%s/", var.team, var.name))}"
  description = "Push-Pull access to ECR"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "cloudwatch_logs" {
  name = "${var.role}-${var.name}-cloudwatch_logs"
  roles = ["${aws_iam_role.admin.name}", "${aws_iam_role.worker.name}"]
  policy_arn = "${aws_iam_policy.cloudwatch_logs.arn}"
}

resource "aws_iam_policy_attachment" "cloudwatch_metrics" {
  name = "${var.role}-${var.name}-cloudwatch_metrics"
  roles = ["${aws_iam_role.admin.name}", "${aws_iam_role.worker.name}"]
  policy_arn = "${aws_iam_policy.cloudwatch_metrics.arn}"
}

resource "aws_iam_policy_attachment" "ecs" {
  name = "${var.role}-${var.name}-ecs"
  roles = ["${aws_iam_role.worker.name}", "${aws_iam_role.admin.name}", "${aws_iam_role.ecsInstance.name}"]
  policy_arn = "${aws_iam_policy.ecs.arn}"
}

resource "aws_iam_policy_attachment" "ecr" {
  name = "${var.role}-${var.name}-ecr"
  roles = ["${aws_iam_role.admin.name}", "${aws_iam_role.worker.name}"]
  policy_arn = "${aws_iam_policy.ecr.arn}"
}

resource "aws_iam_instance_profile" "admin" {
  name = "${var.name}-admin-${var.environment_id}"
  path = "${lower(format("/%s/%s/", var.team, var.name))}"
  roles = ["${aws_iam_role.admin.name}"]
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.name}-worker-${var.environment_id}"
  path = "${lower(format("/%s/%s/", var.team, var.name))}"
  roles = ["${aws_iam_role.worker.name}"]
}
