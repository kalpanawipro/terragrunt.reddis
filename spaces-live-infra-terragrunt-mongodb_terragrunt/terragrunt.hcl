# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  assume_role {
    role_arn = "arn:aws-us-gov:iam::${local.account_id}:role/${local.deployment_role}"
  }
  
  default_tags {
    tags = {
      eks = "true"
    }
  }
}
EOF
}

# This block will configure resources for S3 Backend automatically
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "spaces-tf-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-gov-west-1"
    encrypt        = true
    dynamodb_table = "spaces-terraform-state-lock-ddb"
  }
}

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  #environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name    = local.account_vars.locals.account_name
  account_id      = local.account_vars.locals.aws_account_id
  aws_region      = local.region_vars.locals.aws_region
  deployment_role = local.account_vars.locals.deployment_role
}

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals
)
