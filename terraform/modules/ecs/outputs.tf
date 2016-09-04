output "elb_address" { value = "${aws_elb.web.dns_name}" }
output "elb_zone_id" { value = "${aws_elb.web.zone_id}" }
output "role" { value = "${aws_iam_role.admin.arn}" }
output "worker_role_arn" { value = "${aws_iam_role.worker.arn}" }
output "worker_role_name" { value = "${aws_iam_role.worker.name}" }
output "admin_asg" { value = "${aws_autoscaling_group.admin.name}" }
output "worker_asg" { value = "${aws_autoscaling_group.worker.name}" }
output "public_hostname" { value = "${var.public_hostname}" }
