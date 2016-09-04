output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
output "public" {
  value = ["${aws_subnet.public.*.id}"]
}
output "private" {
  value = ["${aws_subnet.private.*.id}"]
}
output "data" {
  value = ["${aws_subnet.data.*.id}"]
}
output "admin" {
  value = ["${aws_subnet.admin.*.id}"]
}
output "highrisk" {
  value = ["${aws_subnet.highrisk.*.id}"]
}

