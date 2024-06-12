# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# # components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-services/redis?ref=mongoDB_gov"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  cluster_details = ["loc-infra-redis:1:cache.t2.medium", "edm-infra-redis:1:cache.t2.medium", "dms-infra-redis:1:cache.t2.medium"]
}
# Inputs to the source Terraform module
inputs = {

  region                                = "us-gov-west-1"
  instance_ami                          = "ami-0be10152e6aa34b53"
  key_name                              = "sandbox-govcloud"
  iam_instance_profile                  = "ec2-ssm-role"
  subnet_id                             = ["subnet-0e62ed70dc0a47fe5","subnet-0a72ce137ee319ab2","subnet-0879140def8de1a2e"]
  security_group_ids                       = ["sg-051750324704031ed"]
  cluster_id                            = local.cluster_details #"gov-cloud-redis"
  engine                                = "redis"
  #node_type                             = "cache.m6g.large"
  # num_cache_nodes                       = "2"
  parameter_group_name                  = "default.redis7"
  engine_version                        = "7.1"
  port                                  = "6379"
  availability_zone                     = ["us-gov-west-1a", "us-gov-west-1b", "us-gov-west-1c"]
  #subnet_group_name                     = "redis-commons"

  # Enable AWS Managed addons
  # vpc_id                   = dependency.vpc.outputs.vpc_id
  # subnet_ids               = dependency.vpc.outputs.private_subnets
  # control_plane_subnet_ids = dependency.vpc.outputs.private_subnets

}
# dependency "vpc" {
#   config_path = "../vpc"
# }