# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# # components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-services/security_groups?ref=mongoDB_gov"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  # irsa           = yamldecode(file("${get_terragrunt_dir()}/configs/irsa.yaml"))
}
# Inputs to the source Terraform module
inputs = {
    vpc_id = ["vpc-01fd27d3bef41528d"]
}
# dependency "vpc" {
#   config_path = "../vpc"
# }