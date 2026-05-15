module "vpc"{
  source = "../../modules/vpc"
  env             = var.env
  project_name    = var.project_name
  region = var.region
}

module "ecr"{
  source = "../../modules/ecr"
  env             = var.env
  project_name    = var.project_name
  region = var.region
}

module "dynamodb"{
  source = "../../modules/dynamodb"
  project_name    = var.project_name
  env             = var.env
}


module "eks"{
  source = "../../modules/eks"
  env = var.env
  project_name = var.project_name

  #VPC outputs to eks
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  # cluster_security_group_id = module.vpc.cluster_security_group_id
}
