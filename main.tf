module "vpc" {
  source = "./vendor/modules/vpc"
  vpc = var.vpc
  env = var.env
  management_vpc = var.management_vpc
}

module "docdb" {
  source = "./vendor/modules/docdb"
  vpc = var.docdb
  env = var.env
}