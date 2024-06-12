# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# # components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-services/msk?ref=mongoDB_gov"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  cluster_broker_map = ["loc-infra-msk:2:kafka.m5.large", "edm-infra-msk:2:kafka.m5.large"]
}
# Inputs to the source Terraform module
inputs = {

  region = "us-gov-west-1"
  instance_ami = "ami-0be10152e6aa34b53"
  key_name = "sandbox-govcloud"
  iam_instance_profile = "ec2-ssm-role"
  # subnet_id = ["subnet-09516c7409bf71a35","subnet-06247c267748b121e","subnet-053c54c6e590f7443"]
  # security_groups = ["sg-0f965b48a2b92b92b", "sg-0a0704efb66b73d7a"]

  ##config for msk##
  instance_ami_msk = "ami-0be10152e6aa34b53"
  subnet_id_msk = ["subnet-0e62ed70dc0a47fe5", "subnet-0a72ce137ee319ab2"]  #["subnet-09516c7409bf71a35","subnet-06247c267748b121e","subnet-053c54c6e590f7443"]#, "subnet-097fc00a3344605ba"]
  security_groups_msk = ["sg-051750324704031ed"]
  encryptionInfo = "true"
  cluster_broker_map = local.cluster_broker_map
  #var.msk_instanceType = 

  ####end of msk config####
}