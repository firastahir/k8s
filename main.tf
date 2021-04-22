terraform {
  required_version = "~>0.14.0"
}

provider "aws" {
  version = "~> 2.44"
  region  = var.region
  assume_role {
    role_arn     = "arn:aws:iam::598202605839:role/NextGenAdminAccess"
  }
}

module "eks" {
  source          = "./eks"
  name            = var.name
  environment     = var.environment
  region          = var.region
  k8s_version     = var.k8s_version
  vpc_id          = var.vpc_id
  primary_subnet_ids    = var.primary_subnet_ids
  secondary_subnet_ids  = var.secondary_subnet_ids
  kubeconfig_path = var.kubeconfig_path
}

#module "ingress" {
#  source       = "./ingress"
#  name         = var.name
#  environment  = var.environment
#  region       = var.region
#  vpc_id       = var.vpc_id
#  cluster_id   = module.eks.cluster_id
#}