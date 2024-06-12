# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# # components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-subnet?ref=mongoDB_gov"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  # irsa           = yamldecode(file("${get_terragrunt_dir()}/configs/irsa.yaml"))
}
# Inputs to the source Terraform module
inputs = {
  name     = "spaces-eks-subnet-govcloud"
  vpc_id   = "vpc-01fd27d3bef41528d"
  vpc_cidr = "10.20.0.0/16"

  azs             = ["us-gov-west-1a", "us-gov-west-1b", "us-gov-west-1c"]
  private_subnets = ["10.20.32.0/19", "10.20.64.0/19", "10.20.96.0/19"]
  public_subnets  = ["10.20.128.0/19", "10.20.160.0/19", "10.20.192.0/19"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  public_route_table = "rtb-0913c36559545b3e4"
  private_route_table = "rtb-0887bfbaaa3cb0fa3"

  tags = {
    Terraform   = "true"
    Environment = "govcloud-sandbox"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery" = "private"
  }

  environment = "sandbox-govcloud"
}

# dependency "vpc" {
#   config_path = "../vpc"
# }