variable "region" {
  type = "string"
}
variable "name" {
  type = "string"
}
variable "team" {
  type = "string"
}
variable "owner" {
  type = "string"
}
variable "environment" {
  type = "string"
  description = "Set to either Development or Production"
}
variable "ecr" {
  type = "string"
}
variable "ci_version" {
  type = "string"
}
variable "github_app_id" {
  type = "string"
}
variable "github_app_secret" {
  type = "string"
}
variable "hosted_zone_id" {
  type = "string"
  description = "The hosted zone id for the corresponding hosted_zone_name"
}
variable "hosted_zone_name" {
  type = "string"
  description = "The base domain name to register a record under (must have a trailing '.') e.g. demo.ardel.io."
}
variable "ssh_key_name" {
  type = "string"
  description = "The SSH Key to use for access to concourse_admin"
}
variable "ssl_certificate_arn" {
  type = "string"
  description = "ARN for an SSL cert that represents the ConcourseCI website"
}
variable "kms_access_roles" {
  type = "list"
  description = "Roles assigned encrypt/decrypt access to KMS Key"
  default = []
}
