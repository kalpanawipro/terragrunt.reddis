# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# # components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-services/redshift?ref=mongoDB_gov"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  redshift_db_details = ["loc-redshift-cluster:2:ra3.xlplus"]
  # irsa           = yamldecode(file("${get_terragrunt_dir()}/configs/irsa.yaml"))
}
# Inputs to the source Terraform module
inputs = {

  region                              = "us-gov-west-1"
  instance_ami                        = "ami-0be10152e6aa34b53"
  key_name                            = "sandbox-govcloud"
  iam_instance_profile                = "ec2-ssm-role"
  subnet_ids                           = ["subnet-0e62ed70dc0a47fe5","subnet-0a72ce137ee319ab2","subnet-0879140def8de1a2e"]
  security_groups                     = ["sg-051750324704031ed"] #,"sg-0a6878e4b2ff6691f"]
  cluster_identifier                  = local.redshift_db_details
  availability_zone                   = ["us-gov-west-1a", "us-gov-west-1b", "us-gov-west-1c"]
  cluster_public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeJIWFLzTbiwMnpsCNavsqkN5Ep0uD9f/Hts7Iudf1pttQ0Cdee/nurtJ8xOPfqCT/ixzLeNi+/6geS0EoXXYQapEWl/hvb76OjkjGPZqCGh895pHsCTSinfATi1cHwB9NkHhPpEmvMjurdjJ0CUgtI4kTAodTWExQph55TuWFOTd9JpnEZZsEQVEh61jBvEDYKFWnISOjLaAFQdjIg1KQaYNRWCAus4eq6uSqUBivLeOE1SjdOAgpsYrDHNKz9E2i+FGvzDFJi+nECNiBFwxTzj6v/uT7iAz5MawFk8+Rzdec41XLPbh5gVhirqWis2+eXP2JtIIjtZxTV9QZH6VT Amazon-Redshift"
  #"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCFmhHLb0lguyx9ngg6C7nYLYfGn1nAm9t7+viYIKS55p1xHh1PWK9luc2sN+e+28F3HLiYz1OxSyjzyr4Gt41r4/9J/HhgNk7UdNG/H7wBbjJyxWThXlxDNNqHaXL8C8g2w6h5btYJvWymE06bv7ye8CcmWvbx6881jGnj8yfnJaa8eiq26gL2qSfPAECIG6hBa+cxgXvXXMKXhZmq3BxKC5n3sXT9l2ctmstvVO35nL5Fk8PxKPgiErFqZMG6bSKNFcBIk6AVYHmfLV4cXq/6ZOg64Z4n8i4Qo+xtUWWz17YVOmKufvA94j+vU9XZmyWnSwcdA+anw8SGnL1u0D03 Amazon-Redshift"
  cluster_type                        = "multi-node"
  iam_roles                           = ["arn:aws-us-gov:iam::031661760457:role/redshift-user-role"]
  master_password                     = "qNL2UVQ55F5PA"
  master_username                     = "admin"
}
# dependency "vpc" {
#   config_path = "../vpc"
# }