resource "aws_s3_bucket" "assets_logs" {
  bucket = "${var.team}-${var.role}-${var.name}-assets-logs"
  acl = "log-delivery-write"

	tags {
		Name = "${var.name}-assets-logs"
		Project = "${var.name}"
		Team = "${var.team}"
		Owner = "${var.owner}"
		Environment = "${var.environment}"
		EnvironmentId = "${var.environment_id}"
	}
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.team}-${var.role}-${var.name}-assets"
  versioning {
    enabled = true
  }
  acl = "private"
	logging {
		target_bucket = "${aws_s3_bucket.assets_logs.id}"
		target_prefix = "log/"
	}
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetObjectVersion",
        "s3:ListBucketVersions",
        "s3:PutObjectVersionAcl"
      ],
      "Principal": {"AWS": [
        "${var.ecs_worker_role_arn}",
        "${var.iam_ci_user_arn}"
      ]},
      "Resource": [
        "arn:aws:s3:::${var.team}-${var.role}-${var.name}-assets",
        "arn:aws:s3:::${var.team}-${var.role}-${var.name}-assets/*"
      ]
    },
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.team}-${var.role}-${var.name}-assets/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    }
  ]
}
EOF
  tags {
    Name = "${var.name}"
    Project = "${var.name}"
    Team = "${var.team}"
    Owner = "${var.owner}"
    Environment = "${var.environment}"
    EnvironmentId = "${var.environment_id}"
  }
}
