output "vpc" {
  value = module.vpc
}

output "jump_box" {
  value = module.jump_box
}

output "aurora_postgresql" {
  value = module.aurora_postgresql
}
