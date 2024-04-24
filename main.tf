module "vpc" {
  for_each                  = var.vpc
  source                    = "./vendor/modules/vpc"
  cidr_block                = each.value.cidr_block
  additional_cidr_block     = each.value.additional_cidr_block
  private_subnets           = each.value.private_subnets
  public_subnets            = each.value.public_subnets
  subnet_availability_zones = each.value.subnet_availability_zones
  env                       = var.env
  management_vpc            = var.management_vpc
  private_zone_id           = var.private_zone_id
}


module "docdb" {
  for_each = var.docdb
  source = "./vendor/modules/docdb"
  engine              = each.value.engine
  name = each.key
  env = var.env
  subnets = flatten([for i, j in module.vpc : j.private_subnets["database"]["subnets"][*].id])
}

#module "rds" {
#  for_each = var.rds
#  source = "./vendor/modules/rds"
#  name = each.key
#  env = var.env
#  engine              = each.value.engine
#  engine_version      = each.value.engine_version
#  instance_class      = each.value.instance_class
#  skip_final_snapshot = each.value.skip_final_snapshot
#  subnets = flatten([for i, j in module.vpc : j.private_subnets["database"]["subnets"][*].id])
#}

module "elasticache" {
  for_each = var.elasticache
  source = "./vendor/modules/elasticache"
  engine          = each.value.engine
  engine_version  = each.value.engine_version
  node_type       = each.value.node_type
  num_cache_nodes = each.value.num_cache_nodes
  name = each.key
  env = var.env
  subnets         = flatten([for i, j in module.vpc : j.private_subnets["database"]["subnets"][*].id])
}

module "rabbitmq" {
  source          = "./vendor/modules/rabbitmq"
  for_each        = var.rabbitmq
  env             = var.env
  subnets         = flatten([for i, j in module.vpc : j.private_subnets["database"]["subnets"][*].id])
  name            = each.key
  instance_type   = each.value.instance_type
}

module "apps" {
  source        = "./vendor/modules/app-setup"
  env           = var.env
  subnets       = each.key == "frontend" ? flatten([for i, j in module.vpc : j.private_subnets["frontend"]["subnets"][*].id]) : flatten([for i, j in module.vpc : j.private_subnets["app"]["subnets"][*].id])
  for_each      = var.apps
  name          = each.key
  instance_type = each.value.instance_type
  min_size      = each.value.min_size
  max_size      = each.value.max_size
  BASTION_NODE = var.BASTION_NODE
  vpc_id               = element([for i, j in module.vpc : j.vpc_id], 0)
  app_port_no = each.value.app_port_no
  PROMETHEUS_NODE = var.PROMETHEUS_NODE
  vpc_cidr             = element([for i, j in module.vpc : j.vpc_cidr], 0)
  alb                  = module.alb
  private_zone_id      = var.private_zone_id
  lb_listener_priority = each.value.lb_listener_priority
  type                 = each.value.type
  public_dns_name      = try(each.value.public_dns_name, null)
  public_zone_id       = var.public_zone_id
  ACM_ARN = var.ACM_ARN
}

module "alb" {
  source   = "./vendor/modules/alb"
  for_each = local.merged_alb
  env      = var.env
  subnets  = each.value.subnets
  name     = each.key
  vpc_id   = element([for i, j in module.vpc : j.vpc_id], 0)
  vpc_cidr = element([for i, j in module.vpc : j.vpc_cidr], 0)
  internal = each.value.internal
}