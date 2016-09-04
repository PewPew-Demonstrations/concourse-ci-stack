resource "aws_kms_key" "db" {
  description = "${format("Managed by Terraform. ConcourseCI DB Encryption Key (%s-%s-%s)", var.team, var.role, var.name)}"
  deletion_window_in_days = 10
}

resource "aws_db_subnet_group" "default" {
  name = "${lower(var.team)}-${lower(var.role)}-${lower(var.name)}"
  description = "Managed by Terraform"
  subnet_ids = ["${var.db_subnets}"]

  tags {
    Name = "${var.name}"
    EnvID = "${var.environment_id}"
    Project = "${var.name}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.owner}"
  }
}

resource "aws_db_parameter_group" "default" {
  name = "${lower(var.team)}-${lower(var.role)}-${lower(var.name)}"
  family = "postgres9.5"
  description = "Managed by Terraform"
}

resource "aws_db_instance" "default"{
  allocated_storage = 100
  engine = "postgres"
  engine_version = "9.5.2"
  instance_class = "${var.db_instance_type}"
  name = "${var.db_name}"
  username = "${var.db_master_username}"
  password = "${var.db_master_password}"
  storage_type = "gp2"
  copy_tags_to_snapshot = true
  vpc_security_group_ids = ["${var.db_security_groups}"]
  db_subnet_group_name = "${aws_db_subnet_group.default.id}"
  parameter_group_name = "${aws_db_parameter_group.default.id}"
  auto_minor_version_upgrade = true
  storage_encrypted = true
  kms_key_id = "${aws_kms_key.db.arn}"

  tags {
    Name = "${var.name}"
    EnvID = "${var.environment_id}"
    Project = "${var.name}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.owner}"
  }
}
