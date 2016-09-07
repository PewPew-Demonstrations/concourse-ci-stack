resource "aws_kms_key" "ci" {
    description = "KMS Key used by ${var.team}-${var.role}-${var.name}"
    deletion_window_in_days = 7
    enable_key_rotation = true
}

resource "aws_kms_alias" "ci" {
    name = "alias/${var.team}-${var.role}-${var.name}-kms"
    target_key_id = "${aws_kms_key.ci.key_id}"
}

resource "aws_iam_policy" "kms_decrypt" {
  name = "KMS-Decrypt-${var.environment_id}"
  path = "${lower(format("/%s/%s/", var.team, var.name))}"
  description = "Decrypt access to KMS Key "
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": [
        "${aws_kms_key.ci.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "kms_encrypt" {
  name = "KMS-Encrypt-${var.environment_id}"
  path = "${lower(format("/%s/%s/", var.team, var.name))}"
  description = "Encrypt access to KMS Key "
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": [
        "${aws_kms_key.ci.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "kms_decrypt" {
  name = "${var.name}-ci-kms-decrypt"
  roles = ["${compact(concat(list(var.ecs_worker_role_name), var.kms_access_roles))}"]
  users = ["${aws_iam_user.ci.name}"]
  policy_arn = "${aws_iam_policy.kms_decrypt.arn}"
}

resource "aws_iam_policy_attachment" "kms_encrypt" {
  name = "${var.name}-ci-kms-encrypt"
  roles = ["${compact(concat(list(var.ecs_worker_role_name), var.kms_access_roles))}"]
  users = ["${aws_iam_user.ci.name}"]
  policy_arn = "${aws_iam_policy.kms_encrypt.arn}"
}
