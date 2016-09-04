data "aws_ami" "ecs" {
  most_recent = true
  executable_users = ["all"]
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}
