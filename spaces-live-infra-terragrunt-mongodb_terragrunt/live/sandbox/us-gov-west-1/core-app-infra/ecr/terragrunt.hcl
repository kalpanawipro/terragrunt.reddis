include "root" {
  path = find_in_parent_folders()
}

# Source Terraform modules
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-cluster-stack/modules/ecr?ref=main"
}

inputs = {
  repositories = {
    dnaspaces-dbapi-govcloud = {}
    dnaspaces-cds-govcloud = {}
    rightnow-wifi-engine-govcloud = {}
    mapservices-govcloud = {}
    int-api-govcloud = {}
    dnaspaces-location-receiver-govcloud = {}
  }
  allowed_accounts = ["031661760457"]
}
#
