resource "aws_vpc" "main" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = false

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

resource "aws_network_acl" "main" {
  vpc_id = "${aws_vpc.main.id}"

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

resource "aws_subnet" "public" {
  count = "${length(var.zones)}"

  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.cidr, 5, count.index)}"
  availability_zone = "${element(var.zones, count.index)}"

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

resource "aws_subnet" "private" {
  count = "${length(var.zones)}"

  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.cidr, 5, count.index + length(var.zones))}"
  availability_zone = "${element(var.zones, count.index)}"

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

resource "aws_subnet" "data" {
  count = "${length(var.zones)}"

  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.cidr, 5, count.index + (length(var.zones) * 2))}"
  availability_zone = "${element(var.zones, count.index)}"

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

resource "aws_subnet" "admin" {
  count = "${length(var.zones)}"

  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.cidr, 5, count.index + (length(var.zones) * 3))}"
  availability_zone = "${element(var.zones, count.index)}"

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

resource "aws_subnet" "highrisk" {
  count = "${length(var.zones)}"

  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.cidr, 5, count.index + (length(var.zones) * 4))}"
  availability_zone = "${element(var.zones, count.index)}"

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

resource "aws_eip" "ngw" {
  count = "${length(var.zones)}"

  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

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

resource "aws_nat_gateway" "ngw" {
  count = "${length(var.zones)}"

  allocation_id = "${element(aws_eip.ngw.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.igw"]
}

// Route tables for external subnets
resource "aws_route_table" "external" {
  count = "${length(var.zones)}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.name}-external"
    EnvID = "${var.environment_id}"
    Project = "${var.name}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.owner}"
  }
}

resource "aws_route" "external" {
  count = "${length(var.zones)}"

  route_table_id = "${element(aws_route_table.external.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "external_public" {
  count = "${length(var.zones)}"
  route_table_id = "${element(aws_route_table.external.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_route_table_association" "external_highrisk" {
  count = "${length(var.zones)}"
  route_table_id = "${element(aws_route_table.external.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.highrisk.*.id, count.index)}"
}

// Route tables for internal subnets
resource "aws_route_table" "internal" {
  count = "${length(var.zones)}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.name}-internal"
    EnvID = "${var.environment_id}"
    Project = "${var.name}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.owner}"
  }
}

resource "aws_route" "internal" {
  count = "${length(var.zones)}"
  route_table_id = "${element(aws_route_table.internal.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
}

resource "aws_route_table_association" "internal_private" {
  count = "${length(var.zones)}"
  route_table_id = "${element(aws_route_table.internal.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_route_table_association" "internal_data" {
  count = "${length(var.zones)}"
  route_table_id = "${element(aws_route_table.internal.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.data.*.id, count.index)}"
}

resource "aws_route_table_association" "internal_admin" {
  count = "${length(var.zones)}"
  route_table_id = "${element(aws_route_table.internal.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.admin.*.id, count.index)}"
}
