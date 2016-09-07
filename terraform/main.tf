module "vpc" {
  source = "./modules/vpc"

  environment_id = "${random_id.environment_id.b64}"

  name = "${var.name}"
  team = "${var.team}"
  role = "${var.role}"
  owner = "${var.owner}"
  environment = "${var.environment}"

  region = "${var.region}"
  cidr = "${var.vpc_cidr}"
  zones = "${formatlist(format("%s%%s", var.region), var.zones[var.region])}"
}

module "securitygroups" {
  source = "./modules/securitygroups"

  environment_id = "${random_id.environment_id.b64}"

  name = "${var.name}"
  team = "${var.team}"
  role = "${var.role}"
  owner = "${var.owner}"
  environment = "${var.environment}"

  vpc = "${module.vpc.vpc_id}"
}

module "database" {
  source = "./modules/rds"

  environment_id = "${random_id.environment_id.b64}"

  name = "${var.name}"
  team = "${var.team}"
  role = "${var.role}"
  owner = "${var.owner}"
  environment = "${var.environment}"

  db_subnets = ["${module.vpc.data}"]
  db_security_groups = ["${module.securitygroups.data}"]
  db_master_password = "${random_id.db_password.b64}"
  db_name = "${var.db_master_name}"
}

module "ecs" {
  source = "./modules/ecs"

  environment_id = "${random_id.environment_id.b64}"

  name = "${var.name}"
  team = "${var.team}"
  role = "${var.role}"
  owner = "${var.owner}"
  environment = "${var.environment}"

  region = "${var.region}"
  public_hostname = "${format("%s.%s", lower(format("%s-%s-%s", var.team, var.role, var.name)), var.hosted_zone_name)}"
  ssl_certificate_arn = "${var.ssl_certificate_arn}"
  key_name = "${var.ssh_key_name}"
  admin_desired_capacity = "${var.admin_desired_capacity}"
  worker_desired_capacity = "${var.worker_desired_capacity}"

  db_host = "${module.database.host}"
  db_port = "${module.database.port}"
  db_master_user = "${module.database.username}"
  db_master_password = "${module.database.password}"
  ecr = "${var.ecr}"
  ci_version = "${var.ci_version}"

  public_subnets = ["${module.vpc.public}"]
  public_security_groups = ["${module.securitygroups.public}"]
  admin_subnets = ["${module.vpc.admin}"]
  admin_security_groups = ["${module.securitygroups.admin}"]
  worker_subnets = ["${module.vpc.private}"]
  worker_security_groups = ["${module.securitygroups.private}"]

  github_app_id = "${var.github_app_id}"
  github_app_secret = "${var.github_app_secret}"
}

module "route53" {
  source = "./modules/route53"

  domain = "${module.ecs.public_hostname}"

  hosted_zone_id = "${var.hosted_zone_id}"

  elb_address = "${module.ecs.elb_address}"
  elb_zone_id = "${module.ecs.elb_zone_id}"
}

module "s3" {
  source = "./modules/s3"
  ecs_worker_role_name = "${module.ecs.worker_role_name}"
  environment = "${var.environment}"
  environment_id = "${random_id.environment_id.b64}"
  iam_ci_user_arn = "${module.iam.ci_user_arn}"
  name = "${var.name}"
  owner = "${var.owner}"
  role = "${var.role}"
  team = "${var.team}"
}

module "iam" {
  source = "./modules/iam"
  ecs_worker_role_name = "${module.ecs.worker_role_name}"
  environment = "${var.environment}"
  environment_id = "${random_id.environment_id.b64}"
  kms_access_roles = "${var.kms_access_roles}"
  name = "${var.name}"
  owner = "${var.owner}"
  role = "${var.role}"
  team = "${var.team}"
}
