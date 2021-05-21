data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidr = ["10.0.16.0/20", "10.0.32.0/20"]
  availability_zones  = data.aws_availability_zones.available.names
}

module "elb" {
  source             = "./modules/elb"
  vpc_id             = module.vpc.vpc_id
  availability_zones = data.aws_availability_zones.available.names
  subnet_id          = module.vpc.public_subnet_id
  depends_on = [
    module.vpc
  ]
}

module "instance" {
  source            = "./modules/instance"
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  loadbalancer_sg   = module.elb.securitygroup_id
  key               = "Ohio"
  targetgroup_arn   = module.elb.targetgroup_id
  image_id          = "ami-0f4aeaec5b3ce9152"
  depends_on = [
    module.elb
  ]
}
