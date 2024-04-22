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
#  private_zone_id           = var.private_zone_id
}


module "docdb" {
  for_each = var.docdb
  source = "./vendor/modules/docdb"
  engine              = each.value.engine
  name = each.key
  env = var.env
  subnets = flatten([for i, j in module.vpc : j.private_subnets["database"]["subnets"][*].id])
}
#
#module "rds" {
#  source = "./vendor/modules/rds"
#  rds = var.rds
#  env = var.env
#  subnets = flatten([for i, j in module.vpc : j.private_subnets["database"]["subnets"][*].id])
#}