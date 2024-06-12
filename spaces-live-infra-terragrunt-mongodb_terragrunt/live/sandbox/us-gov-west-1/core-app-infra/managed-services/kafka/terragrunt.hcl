# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# # components and environments, such as how to configure remote state.

# include "root" {
#   path = find_in_parent_folders()
# }

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-services/kafka?ref=mongoDB_gov"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  instance_list_kafka = split("\n", file("kafka_instance_broker.config") )
}
# Inputs to the source Terraform module
inputs = {
  region = "us-gov-west-1"
  ssl_enabled = "false"
  instance_type = "c5.xlarge"
  instance_ami = "ami-0b45eebe9452a384d"
  key_name = "sandbox-govcloud"
  iam_instance_profile = "ec2-ssm-role"
  subnet_id = ["subnet-0e62ed70dc0a47fe5","subnet-0a72ce137ee319ab2","subnet-0879140def8de1a2e"]
  security_groups = ["sg-051750324704031ed"]
  useLocalDisk = "false"
  instance_list_kafka = local.instance_list_kafka
}