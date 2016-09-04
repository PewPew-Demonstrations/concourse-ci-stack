variable "db_instance_type" {
  type = "string"
  default = "db.m3.medium"
}
variable "db_master_password" { type = "string" }
variable "db_master_username" {
  type = "string"
  default = "postgres"
}
variable "db_name" {
  type = "string"
  default = "postgres"
}
variable "db_security_groups" { type = "list" }
variable "db_subnets" { type = "list" }
variable "environment" { type = "string" }
variable "environment_id" { type = "string" }
variable "name" { type = "string" }
variable "owner" { type = "string" }
variable "role" { type = "string" }
variable "team" { type = "string" }
