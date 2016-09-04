resource "template_file" "admin_user_data" {
  template = "${file("${path.module}/user-data.tpl")}"
  vars {
    cluster_name = "${aws_ecs_cluster.admin.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "template_file" "worker_user_data" {
  template = "${file("${path.module}/user-data.tpl")}"
  vars {
    cluster_name = "${aws_ecs_cluster.worker.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
