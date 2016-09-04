resource "aws_security_group" "public" {
  name_prefix = "${var.name}_public_"
  vpc_id = "${var.vpc}"

  tags {
    Name = "${var.name}-public"
    EnvID = "${var.environment_id}"
    Project = "${var.name}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.owner}"
  }
}
resource "aws_security_group" "private" {
  name_prefix = "${var.name}_private_"
  vpc_id = "${var.vpc}"

  tags {
    Name = "${var.name}-private"
    EnvID = "${var.environment_id}"
    Project = "${var.name}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.owner}"
  }
}
resource "aws_security_group" "data" {
  name_prefix = "${var.name}_data_"
  vpc_id = "${var.vpc}"

  tags {
    Name = "${var.name}-data"
    EnvID = "${var.environment_id}"
    Project = "${var.name}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group" "admin" {
  name_prefix = "${var.name}_admin_"
  vpc_id = "${var.vpc}"

  tags {
    Name = "${var.name}-admin"
    EnvID = "${var.environment_id}"
    Project = "${var.name}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group" "highrisk" {
  name_prefix = "${var.name}_highrisk_"
  vpc_id = "${var.vpc}"

  tags {
    Name = "${var.name}-highrisk"
    EnvID = "${var.environment_id}"
    Project = "${var.name}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.owner}"
  }
}

// Connecting to the outside
resource "aws_security_group_rule" "public_external_out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.public.id}"
}

resource "aws_security_group_rule" "private_external_out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.private.id}"
}

resource "aws_security_group_rule" "data_external_out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.data.id}"
}

resource "aws_security_group_rule" "admin_external_out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.admin.id}"
}

resource "aws_security_group_rule" "highrisk_external_out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.highrisk.id}"
}

// Self-referencing ingresses
resource "aws_security_group_rule" "public_public_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.public.id}"
  self = true
}

resource "aws_security_group_rule" "private_private_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.private.id}"
  self = true
}

resource "aws_security_group_rule" "data_data_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.data.id}"
  self = true
}

resource "aws_security_group_rule" "admin_admin_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.admin.id}"
  self = true
}

resource "aws_security_group_rule" "highrisk_highrisk_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.highrisk.id}"
  self = true
}

// Connecting to public security group
resource "aws_security_group_rule" "http_public_in" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"

  security_group_id = "${aws_security_group.public.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_public_in" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"

  security_group_id = "${aws_security_group.public.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "apps_public_in" {
  type = "ingress"
  from_port = 3000
  to_port = 9000
  protocol = "tcp"

  security_group_id = "${aws_security_group.public.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "private_public_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.public.id}"
  source_security_group_id = "${aws_security_group.private.id}"
}

resource "aws_security_group_rule" "admin_public_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.public.id}"
  source_security_group_id = "${aws_security_group.admin.id}"
}

resource "aws_security_group_rule" "highrisk_public_in" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"

  security_group_id = "${aws_security_group.public.id}"
  source_security_group_id = "${aws_security_group.highrisk.id}"
}

// Connecting to private security group
resource "aws_security_group_rule" "data_private_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.private.id}"
  source_security_group_id = "${aws_security_group.data.id}"
}

resource "aws_security_group_rule" "admin_private_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.private.id}"
  source_security_group_id = "${aws_security_group.admin.id}"
}

resource "aws_security_group_rule" "highrisk_private_in" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"

  security_group_id = "${aws_security_group.private.id}"
  source_security_group_id = "${aws_security_group.highrisk.id}"
}

// Connecting to data security group
resource "aws_security_group_rule" "private_data_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.data.id}"
  source_security_group_id = "${aws_security_group.private.id}"
}

resource "aws_security_group_rule" "admin_data_in" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.data.id}"
  source_security_group_id = "${aws_security_group.admin.id}"
}

resource "aws_security_group_rule" "highrisk_data_in" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"

  security_group_id = "${aws_security_group.data.id}"
  source_security_group_id = "${aws_security_group.highrisk.id}"
}

// Connecting to admin security group
resource "aws_security_group_rule" "highrisk_admin_in" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"

  security_group_id = "${aws_security_group.admin.id}"
  source_security_group_id = "${aws_security_group.highrisk.id}"
}

resource "aws_security_group_rule" "private_admin_in" {
  type = "ingress"
  from_port = 2222
  to_port = 2222
  protocol = "tcp"

  security_group_id = "${aws_security_group.admin.id}"
  source_security_group_id = "${aws_security_group.private.id}"
}

resource "aws_security_group_rule" "public_admin_in" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"

  security_group_id = "${aws_security_group.admin.id}"
  source_security_group_id = "${aws_security_group.public.id}"
}

// Connecting to highrisk security group
resource "aws_security_group_rule" "http_highrisk_in" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"

  security_group_id = "${aws_security_group.highrisk.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_highrisk_in" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"

  security_group_id = "${aws_security_group.highrisk.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh_highrisk_in" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"

  security_group_id = "${aws_security_group.highrisk.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

