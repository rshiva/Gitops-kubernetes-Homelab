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

}
