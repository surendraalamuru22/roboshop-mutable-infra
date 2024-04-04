module "vpc" {
  source = "./vendor/modules/vpc"
  vpc_cidr = var.vpc_cidr
}
