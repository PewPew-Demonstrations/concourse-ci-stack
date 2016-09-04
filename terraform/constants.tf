variable "role" {
  type = "string"
  default = "cd"
}

variable "zones" {
  type = "map"
  default = {
    us-east-1 = ["a", "b", "c"]
    ap-southeast-2 = ["a", "b", "c"]
  }
}

variable "application" {
  type = "string"
  default = "ConcourseCI"
}

variable "db_master_name" {
  type = "string"
  default = "postgres"
}

variable "vpc_cidr" {
  type = "string"
  default = "10.0.0.0/16"
}

variable "admin_desired_capacity" {
  type = "string"
  default = 1
}

variable "worker_desired_capacity" {
  type = "string"
  default = 1
}
