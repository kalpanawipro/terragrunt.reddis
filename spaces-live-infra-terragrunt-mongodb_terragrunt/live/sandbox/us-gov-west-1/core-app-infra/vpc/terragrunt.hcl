include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-vpc-stack?ref=main"
}

inputs = {
  name     = "spaces-eks-cluster-vpc-govcloud"
  vpc_cidr = "172.19.0.0/16"

  azs             = ["us-gov-west-1a", "us-gov-west-1b", "us-gov-west-1c"]
  private_subnets = ["172.19.0.0/19", "172.19.32.0/19", "172.19.64.0/19"]
  public_subnets  = ["172.19.96.0/19", "172.19.128.0/19", "172.19.160.0/19"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "sandbox"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery" = "private"
  }
}

