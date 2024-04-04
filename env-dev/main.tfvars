env = "dev"

vpc = {
  vpc1 = {
    cidr_block = "10.0.0.0/16"
    additional_cidr_block = ["10.1.0.0/16", "10.2.0.0/16"]
  }
}