# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# # components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-services/neptuneDB?ref=mongoDB_gov"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  neptunedb_details = ["sandboxneptundbtest:2:db.r6i.large", "sandbox2:2:db.r6i.large"]
  # irsa           = yamldecode(file("${get_terragrunt_dir()}/configs/irsa.yaml"))
}
# Inputs to the source Terraform module
inputs = {
  #instance_class = "db.r6i.large"
  #num_instance = "2"
  #cluster_identifier = ["sandboxneptundbtest", "sandbox2"]
  neptunedb_details = local.neptunedb_details
  vpc_security_group_neptunedb = ["sg-051750324704031ed"]
  subnet_id_ndb           =["subnet-0e62ed70dc0a47fe5","subnet-0a72ce137ee319ab2","subnet-0879140def8de1a2e"]
  subnet_group_name_ndb           = "neptunedbsubnet"
}

# dependency "vpc" {
#   config_path = "../vpc"
# }
