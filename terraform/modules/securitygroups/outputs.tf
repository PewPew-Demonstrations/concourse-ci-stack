output "public" { value = "${aws_security_group.public.id}" }
output "private" { value = "${aws_security_group.private.id}" }
output "data" { value = "${aws_security_group.data.id}" }
output "admin" { value = "${aws_security_group.admin.id}" }
output "highrisk" { value = "${aws_security_group.highrisk.id}" }
