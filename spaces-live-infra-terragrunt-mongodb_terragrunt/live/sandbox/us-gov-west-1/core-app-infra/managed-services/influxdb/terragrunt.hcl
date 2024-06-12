# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# # components and environments, such as how to configure remote state.

# include "root" {
#   path = find_in_parent_folders()
# }

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-services/influxdb?ref=mongoDB_gov"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  ############["instancetype:bucket_name:influx_endpoint:instance_name_prefix"]########################
  influxdb_details = ["m6g.large:2:eks_metrics:eks-influx.devgov.ciscospaces.io:eks-sandbox-influxdb"]
}
# Inputs to the source Terraform module
inputs = {
        influxdb_details = local.influxdb_details
        region = "us-gov-west-1"
        environment = "dev"
        # instance_type = "m6g.large"
        key_name = "sandbox-govcloud"
        iam_instance_profile = "ec2-ssm-role"
        # countVal = "1"   
        # security_groups = ["sg-0f965b48a2b92b92b", "sg-0a0704efb66b73d7a"]
        listener_arn = "arn:aws-us-gov:elasticloadbalancing:us-gov-west-1:031661760457:listener/app/infra-int-InfluxProd-lb-govcloud/aece008ac989b7a7/d39ad85860299479"
        # bucket_name = "eks_metrics"
        subnet_id = ["subnet-0e62ed70dc0a47fe5","subnet-0a72ce137ee319ab2","subnet-0879140def8de1a2e"]
        security_groups = ["sg-051750324704031ed"]
        useLocalDisk = true
        # endpoint_influx = "eks-influx.devgov.ciscospaces.io"
        instance_ami = "ami-0be10152e6aa34b53"
}