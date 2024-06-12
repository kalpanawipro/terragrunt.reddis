# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# # components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-services/rds?ref=mongoDB_gov"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  rds_details = ["loc-infra-pg:14.10:postgres", "dms-infra-pg:14.10:postgres", "audittrail-parser-govcloud:14.10:postgres"]
  aurora_rds_detais = ["edm-infra-pg:12.12:aurora-postgresql:db.r6g.12xlarge"]
}
# Inputs to the source Terraform module
inputs = {

###config for rds###
  identifier                            = local.rds_details #"density-sg-eventlog-pg"
  aurora_identifier                     = local.aurora_rds_detais
  secretPassword                        = "QNL2UVQ55F5PA"
  instance_class                        = "db.m5.large"
  license_model                         = "postgresql-license"
  maintainence_window                    = "thu:04:24-thu:04:54"
  subnet_id_rds                         =  ["subnet-0e62ed70dc0a47fe5","subnet-0a72ce137ee319ab2","subnet-0879140def8de1a2e"]
  subnet_group_name                     = "rds-opsstack-subnet-group"
  security_groups_rds                   = ["sg-051750324704031ed"]#["sg-0abfb26b920059d68","sg-0a6878e4b2ff6691f"]

}
