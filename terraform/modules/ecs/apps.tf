resource "aws_cloudwatch_log_group" "pgbootstraplogs" {
  name = "${format("%s-%s-%s.pgbootstrap", var.team, var.role, var.name)}"
  retention_in_days = 3
}
resource "aws_cloudwatch_log_group" "adminlogs" {
  name = "${format("%s-%s-%s.admin", var.team, var.role, var.name)}"
  retention_in_days = 3
}
resource "aws_cloudwatch_log_group" "workerlogs" {
  name = "${format("%s-%s-%s.worker", var.team, var.role, var.name)}"
  retention_in_days = 3
}

resource "aws_ecs_task_definition" "admin" {
  family = "${format("%s-%s-%s", var.name, "concourseadmin", var.environment_id)}"
  depends_on = ["aws_cloudwatch_log_group.pgbootstraplogs", "aws_cloudwatch_log_group.adminlogs"]
  container_definitions = <<EOF
[
  {
    "name": "pgbootstrap",
    "essential": false,
    "memory": 256,
    "image": "${format("%s/%s:%s", var.ecr, "concourse-pgbootstrap", var.ci_version)}",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${format("%s-%s-%s.pgbootstrap", var.team, var.role, var.name)}",
        "awslogs-region": "${var.region}"
      }
    },
    "environment": [
      {"name": "PGHOST", "value": "${var.db_host}"},
      {"name": "PGPORT", "value": "${var.db_port}"},
      {"name": "PGUSER", "value": "${var.db_master_user}"},
      {"name": "PGPASSWORD", "value": "${var.db_master_password}"},
      {"name": "CONCOURSE_DB", "value": "${var.db_name}"},
      {"name": "CONCOURSE_DB_USER", "value": "${var.concourse_user}"},
      {"name": "CONCOURSE_DB_PASSWORD", "value": "${var.concourse_password}"}
    ]
  },
  {
    "name": "concourse-admin",
    "essential": true,
    "image": "${format("%s/%s:%s", var.ecr, "concourse-admin", var.ci_version)}",
    "memory": 7168,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${format("%s-%s-%s.admin", var.team, var.role, var.name)}",
        "awslogs-region": "${var.region}"
      }
    },
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      },
      {
        "containerPort": 2222,
        "hostPort": 2222,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {"name": "CONCOURSE_DB", "value": "${var.db_name}"},
      {"name": "CONCOURSE_DB_HOST", "value": "${var.db_host}"},
      {"name": "CONCOURSE_DB_PORT", "value": "${var.db_port}"},
      {"name": "CONCOURSE_DB_USER", "value": "${var.concourse_user}"},
      {"name": "CONCOURSE_DB_PASSWORD", "value": "${var.concourse_password}"},
      {"name": "CONCOURSE_URL", "value": "https://${var.public_hostname}"},
      {"name": "CONCOURSE_GITHUB_CLIENT", "value": "${var.github_app_id}"},
      {"name": "CONCOURSE_GITHUB_SECRET", "value": "${var.github_app_secret}"},
      {"name": "CONCOURSE_GITHUB_ORG", "value": "PewPew-Demonstrations"}
    ]
  }
]
EOF
}

resource "aws_ecs_task_definition" "worker" {
  family = "${format("%s-%s-%s", var.name, "concourseworker", var.environment_id)}"
  depends_on = ["aws_cloudwatch_log_group.workerlogs", "aws_ecs_task_definition.admin"]
  volume {
    name = "worker-workdir"
    host_path = "/ecs/opt/concourse"
  }
  container_definitions = <<EOF
[
  {
    "name": "concourse-worker",
    "memory": 7168,
    "image": "${format("%s/%s:%s", var.ecr, "concourse-worker", var.ci_version)}",
    "privileged": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${format("%s-%s-%s.worker", var.team, var.role, var.name)}",
        "awslogs-region": "${var.region}"
      }
    },
    "environment": [
      {"name": "CONCOURSE_TSA_HOST", "value": "${aws_elb.ssh.dns_name}"}
    ],
    "mountPoints": [
      {
        "sourceVolume": "worker-workdir",
        "containerPath": "/opt/concourse"
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "admin" {
  depends_on = ["aws_iam_role.admin"]
  name = "concourse-admin"
  cluster = "${aws_ecs_cluster.admin.id}"
  task_definition = "${aws_ecs_task_definition.admin.arn}"
  desired_count = "${aws_autoscaling_group.admin.max_size}"
  iam_role = "${aws_iam_role.admin.arn}"
  deployment_minimum_healthy_percent = 0

  load_balancer {
    elb_name = "${aws_elb.web.name}"
    container_name = "concourse-admin"
    container_port = 8080
  }
}

resource "aws_ecs_service" "worker" {
  depends_on = ["aws_iam_role.worker"]
  name = "concourse-worker"
  cluster = "${aws_ecs_cluster.worker.id}"
  task_definition = "${aws_ecs_task_definition.worker.arn}"
  desired_count = "${aws_autoscaling_group.worker.max_size}"
  deployment_minimum_healthy_percent = 0
}
