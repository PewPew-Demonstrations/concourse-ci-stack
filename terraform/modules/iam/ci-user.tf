resource "aws_iam_user" "ci" {
  name = "${var.team}-${var.role}-${var.name}"
}
