variable "ci_version" { type = "string" }
variable "ecr" { type = "string" }
variable "region" { type = "string" }

variable "environment" { type = "string" }
variable "environment_id" { type = "string" }
variable "name" { type = "string" }
variable "owner" { type = "string" }
variable "role" { type = "string" }
variable "team" { type = "string" }

variable "public_hostname" { type = "string" }
variable "ssl_certificate_arn" { type = "string" }

variable "public_security_groups" { type = "list" }
variable "public_subnets" { type = "list" }

variable "admin_desired_capacity" { type = "string" }
variable "admin_instance_type" {
  type = "string"
  default = "m4.large"
}
variable "admin_security_groups" { type = "list" }
variable "admin_subnets" { type = "list" }

variable "worker_desired_capacity" { type = "string" }
variable "worker_instance_type" {
  type = "string"
  default = "m4.large"
}
variable "worker_security_groups" { type = "list" }
variable "worker_subnets" { type = "list" }

variable "github_app_id" { type = "string" }
variable "github_app_secret" { type = "string" }

variable "key_name" { type = "string" }

variable "db_host" { type = "string" }
variable "db_master_user" { type = "string" }
variable "db_master_password" { type = "string" }
variable "db_name" {
  type = "string"
  default = "concourse"
}
variable "db_port" { type = "string" }


variable "concourse_user" {
  type = "string"
  default = "concourse_admin"
}
variable "concourse_password" {
  type = "string"
  default = "password"
}
