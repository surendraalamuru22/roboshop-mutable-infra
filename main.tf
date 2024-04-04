module "vpc" {
  source = "./vendor/modules/vpc"
  vpc = var.vpc
  env = var.env
}
