module "eks" { 
  source = "./eks"
}

module "ingress" {
  source = "./ingress"
}

module "service" {
  source = "./service"
  
}