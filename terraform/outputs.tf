output "environment_id" { value = "${random_id.environment_id.b64}" }
output "public_url" { value = "${module.ecs.public_hostname}" }
output "ecs_worker_role_name" { value = "${module.ecs.worker_role_name}"}
output "ecs_worker_role_arn" { value = "${module.ecs.worker_role_arn}"}
