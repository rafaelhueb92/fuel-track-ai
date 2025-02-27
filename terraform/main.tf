provider "aws" {
  region = "us-east-1"

  # Default tags for all resources
  default_tags {
    tags = {
      Environment = "prod"
      Project     = "fuel-track-ai"
    }
  }
}

terraform {
  backend "s3" {}
}

module db {
  source = "./db"
}

module "network" {
  source = "./network"
}

module "kubernetes" {
  source = "./kubernetes"

  depends_on = [module.roles,module.my-eks-vpc]

}