# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

# Source Terraform modules#
terraform {
  source = "git::http://52.222.34.71:8081/dnaspaces/spaces-terraform-modules.git//modules/eks-cluster-stack?ref=main"
}
locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  irsa           = yamldecode(file("${get_terragrunt_dir()}/configs/irsa.yaml"))
}
# Inputs to the source Terraform module
inputs = {
  cluster_name                   = "spaces-sandbox-eks-cluster"
  cluster_version                = "1.28"
  cluster_endpoint_public_access = true

  # Enable AWS Managed addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.private_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["i3.xlarge"]
  }
//
  eks_managed_node_groups = {
    spot = {
      min_size       = 0
      max_size       = 5
      desired_size   = 3
      instance_types = ["i3.4xlarge"]
      capacity_type  = "ON_DEMAND"
      labels = {
        large = "true"
      }
      launch_template_version = 1
    }
  }

  # Enable/Disbale addons, other than the AWS managed ones
  enable_aws_efs_csi_driver                    = false
  enable_aws_fsx_csi_driver                    = false
  enable_argocd                                = true
  enable_argo_rollouts                         = false
  enable_argo_workflows                        = false
  enable_aws_cloudwatch_metrics                = false
  enable_aws_privateca_issuer                  = false
  enable_cert_manager                          = false
  enable_cluster_autoscaler                    = false
  enable_secrets_store_csi_driver              = true
  enable_secrets_store_csi_driver_provider_aws = true
  enable_kube_prometheus_stack                 = true
  enable_external_dns                          = false
  enable_external_secrets                      = false
  enable_gatekeeper                            = true
  enable_aws_load_balancer_controller          = true
  manage_aws_auth_configmap                    = true
  enable_istio                                 = false
  enable_tetrate_istio                         = true
  enable_karpenter                             = true
  enable_openebs                               = true
  enable_volume_cleanup                        = true
  enable_metrics_server                        = true

  argocd_configs = {
    gitlab_token_secret_arn = "arn:aws-us-gov:secretsmanager:us-gov-west-1:031661760457:secret:argocd/gitlab/token-4upFeF"
  }

  tetrate_custom_configs = {
    tetrate_apikey = "arn:aws-us-gov:secretsmanager:us-gov-west-1:031661760457:secret:tetrate-istio/image-creds-zXXQjV"
  }

  aws_auth_roles = [
    {
      rolearn  = "arn:aws-us-gov:iam::${local.aws_account_id}:role/AWSReservedSSO_AdministratorAccess_a6cb3be50540ad7e"
      username = "admin"
      groups = [
        "system:masters"
      ]
    },
    {
      rolearn  = "arn:aws-us-gov:iam::${local.aws_account_id}:role/admin"
      username = "admin"
      groups = [
        "system:masters"
      ]
    },
    {
      rolearn  = "arn:aws-us-gov:iam::${local.aws_account_id}:role/devops"
      username = "devops"
      groups = [
        "system:masters"
      ]
    },
    {
      rolearn  = "arn:aws-us-gov:iam::${local.aws_account_id}:role/argocd-spoke-sandbox"
      username = "sandbox"
      groups = [
        "system:masters"
      ]
    },
    {
      rolearn  = "arn:aws-us-gov:iam::${local.aws_account_id}:role/spaces-tf-execution-role"
      username = "terraform"
      groups = [
        "system:masters"
      ]
    }
  ]
  irsa_configs = local.irsa.roles
  environment  = "sandbox"
  karpenter_configs = {
    cpu_limit      = "2000"
    memory_limit   = "2000Gi"
    instance_types = ["i3.large", "i3.xlarge", "i3.2xlarge", "i3.4xlarge", "i3.8xlarge", "i3.16xlarge"]
    capacity_type  = ["spot", "on-demand"]
    consolidation  = true
    subnet_tag     = "private"
    labels = {
      large  = "true"
      intent = "apps"
    }
  }
  dashboard_frontend_ingress = true
  dashboard_api_ingress      = true
  ingress_cert               = "arn:aws-us-gov:acm:us-gov-west-1:031661760457:certificate/a3142e95-0d3f-4813-a723-904f469168b0"



  //   security_groups = {
  //     allow_vpn_ranges_sg = {
  //       name        = "AllowVPNRanges"
  //       description = "Allow VPN Ranges"
  //       vpc_id      = dependency.vpc.outputs.vpc_id
  //       ingress_rules = {
  //         AllowVPNRanges = {
  //           description = "Allow VPN Ranges"
  //           from_port   = 0
  //           to_port     = 0
  //           protocol    = "-1"
  //           cidr_blocks = [
  //             "161.44.0.0/16", "173.36.0.0/14", "198.92.0.0/18", "64.101.0.0/18", "72.163.0.0/16", "128.107.0.0/16", "64.101.224.0/19", "171.68.0.0/14", "216.128.32.0/19", "64.101.128.0/18", "66.187.208.0/20", "64.102.0.0/16", "144.254.0.0/16", "64.68.96.0/19", "64.103.0.0/16", "64.104.0.0/16", "64.101.192.0/19", "64.101.64.0/18", "64.100.0.0/16"
  //           ]
  //         }
  //       }
  //       egress_rules = {
  //         AllowAll = {
  //           description = "Allow Egress"
  //           from_port   = 0
  //           to_port     = 0
  //           protocol    = "-1"
  //           cidr_blocks = ["0.0.0.0/0"]
  //         }
  //       }
  //     }
  //     allow_ha_proxy_sg = {
  //       name        = "AllowHAProxy"
  //       description = "Allow HA Proxy"
  //       vpc_id      = dependency.vpc.outputs.vpc_id
  //       ingress_rules = {
  //         AllowHAProxy = {
  //           description              = "Allow HA Proxy"
  //           from_port                = 0
  //           to_port                  = 0
  //           protocol                 = "-1"
  //           source_security_group_id = "sg-025d8bb2053e19ad5"
  //         }
  //       }
  //       egress_rules = {
  //         AllowAll = {
  //           description = "Allow Egress"
  //           from_port   = 0
  //           to_port     = 0
  //           protocol    = "-1"
  //           cidr_blocks = ["0.0.0.0/0"]
  //         }
  //       }
  //     }
  //     nlb_sg = {
  //       name        = "SandboxNLBSG"
  //       description = "Common NLB SG"
  //       vpc_id      = dependency.vpc.outputs.vpc_id
  //       egress_rules = {
  //         AllowAll = {
  //           description = "Allow Egress"
  //           from_port   = 0
  //           to_port     = 0
  //           protocol    = "-1"
  //           cidr_blocks = ["0.0.0.0/0"]
  //         }
  //       }
  //     }
  //     allow_nlb_sg = {
  //       name        = "AllowNLBSG"
  //       description = "Common Sandbox WorkerNode SG"
  //       vpc_id      = dependency.vpc.outputs.vpc_id
  //       ingress_rules = {
  //         AllowNLB = {
  //           description              = "Allow NLB SG"
  //           from_port                = 0
  //           to_port                  = 0
  //           protocol                 = "-1"
  //           source_security_group_id = "sg-0b7ce82bc0d7a3b7e"
  //         }
  //       }
  //     }
  //   }

  //   network_load_balancers = {
  //     SLAgentSandbox = {
  //       lb_name         = "slagent-eks-sandbox"
  //       internal        = true
  //       subnets         = dependency.vpc.outputs.private_subnets
  //       security_groups = ["sg-05ae99922a9896a54", "sg-0b7ce82bc0d7a3b7e", "sg-019a34f5bb7e5f05e"] #AllowHAProxy, SandboxNLBCommon
  //       target_groups = {
  //         "SL8080" = {
  //           name     = "slagent-sandbox-8080"
  //           port     = 8080
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //         "SL8989" = {
  //           name     = "slagent-sandbox-8989"
  //           port     = 8989
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //       }
  //       listeners = {
  //         "SL80" = {
  //           port         = 80
  //           protocol     = "TCP"
  //           target_group = "SL8080"
  //         }
  //         "SL8989" = {
  //           port         = 8989
  //           protocol     = "TCP"
  //           target_group = "SL8989"
  //         }
  //       }
  //     }

  //     LocationRecieverSandbox = {
  //       lb_name         = "location-receiver-eks-sandbox"
  //       internal        = true
  //       subnets         = dependency.vpc.outputs.private_subnets
  //       security_groups = ["sg-05ae99922a9896a54", "sg-0b7ce82bc0d7a3b7e", "sg-019a34f5bb7e5f05e"] #AllowHAProxy, SandboxNLBCommon
  //       target_groups = {
  //         "LR1883" = {
  //           name     = "lr-sandbox-1883"
  //           port     = 1883
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //         "LR9185" = {
  //           name     = "lr-sandbox-9185"
  //           port     = 9185
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //       }
  //       listeners = {
  //         "LR1883" = {
  //           port         = 1883
  //           protocol     = "TCP"
  //           target_group = "LR1883"
  //         }
  //         // "LR9185" = {
  //         //   port         = 9185
  //         //   protocol     = "TCP"
  //         //   target_group = "LR9185"
  //         // }
  //       }
  //     }
  //     LocationRecieverPreprod = {
  //       lb_name         = "location-receiver-eks-preprod"
  //       internal        = true
  //       subnets         = dependency.vpc.outputs.private_subnets
  //       security_groups = ["sg-05ae99922a9896a54", "sg-0b7ce82bc0d7a3b7e", "sg-019a34f5bb7e5f05e"] #AllowHAProxy, SandboxNLBCommon
  //       target_groups = {
  //         "LR1883" = {
  //           name     = "lr-preprod-1883"
  //           port     = 1883
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //         "LR9185" = {
  //           name     = "lr-preprod-9185"
  //           port     = 9185
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //       }
  //       listeners = {
  //         "LR1883" = {
  //           port         = 1883
  //           protocol     = "TCP"
  //           target_group = "LR1883"
  //         }
  //         "LR9185" = {
  //           port         = 9185
  //           protocol     = "TCP"
  //           target_group = "LR9185"
  //         }
  //       }
  //     }
  //     LocationRecieverProd = {
  //       lb_name         = "location-receiver-eks-prod"
  //       internal        = true
  //       subnets         = dependency.vpc.outputs.private_subnets
  //       security_groups = ["sg-05ae99922a9896a54", "sg-0b7ce82bc0d7a3b7e", "sg-019a34f5bb7e5f05e"] #AllowHAProxy, SandboxNLBCommon
  //       target_groups = {
  //         "LR1883" = {
  //           name     = "lr-prod-1883"
  //           port     = 1883
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //         "LR9185" = {
  //           name     = "lr-prod-9185"
  //           port     = 9185
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //       }
  //       listeners = {
  //         "LR1883" = {
  //           port         = 1883
  //           protocol     = "TCP"
  //           target_group = "LR1883"
  //         }
  //         "LR9185" = {
  //           port         = 9185
  //           protocol     = "TCP"
  //           target_group = "LR9185"
  //         }
  //       }
  //     }
  //     RMSSandbox = {
  //       lb_name         = "rms-eks-sandbox"
  //       internal        = true
  //       subnets         = dependency.vpc.outputs.private_subnets
  //       security_groups = ["sg-05ae99922a9896a54", "sg-0b7ce82bc0d7a3b7e", "sg-019a34f5bb7e5f05e"] #AllowHAProxy, SandboxNLBCommon
  //       target_groups = {
  //         "RMS80" = {
  //           name     = "rms-sandbox-80"
  //           port     = 80
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //       }
  //       listeners = {
  //         "RMS80" = {
  //           port         = 80
  //           protocol     = "TCP"
  //           target_group = "RMS80"
  //         }
  //       }
  //     }

  //     PluginAPISRVSandbox = {
  //       lb_name         = "plapisrv-sandbox"
  //       internal        = true
  //       subnets         = dependency.vpc.outputs.private_subnets
  //       security_groups = ["sg-05ae99922a9896a54", "sg-0b7ce82bc0d7a3b7e", "sg-019a34f5bb7e5f05e"] #AllowHAProxy, SandboxNLBCommon
  //       target_groups = {
  //         "PLAPISRV8081" = {
  //           name     = "plapisrv-sandbox-8081"
  //           port     = 8081
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //         "PLAPISRV8082" = {
  //           name     = "plapisrv-sandbox-8082"
  //           port     = 8082
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //       }
  //       listeners = {
  //         "PLAPISRV8081" = {
  //           port         = 8081
  //           protocol     = "TCP"
  //           target_group = "PLAPISRV8081"
  //         }
  //         "PLAPISRV8082" = {
  //           port         = 8082
  //           protocol     = "TCP"
  //           target_group = "PLAPISRV8082"
  //         }
  //       }
  //     }
  //     OpenRoamingHotspotServer = {
  //       lb_name         = "or-hotspot-eks-sandbox"
  //       internal        = true
  //       subnets         = dependency.vpc.outputs.private_subnets
  //       security_groups = ["sg-05ae99922a9896a54", "sg-0b7ce82bc0d7a3b7e", "sg-019a34f5bb7e5f05e"] #AllowHAProxy, SandboxNLBCommon
  //       target_groups = {
  //         "ORHS2083" = {
  //           name     = "orhs-sandbox-2083"
  //           port     = 2083
  //           protocol = "TCP"
  //           vpc_id   = dependency.vpc.outputs.vpc_id
  //         }
  //       }
  //       listeners = {
  //         "ORHS2083" = {
  //           port         = 2083
  //           protocol     = "TCP"
  //           target_group = "ORHS2083"
  //         }
  //       }
  //   }
  // }

  //   node_security_group_additional_rules = {
  //     AllowNLB = {
  //       type                     = "ingress"
  //       description              = "Allow NLB SG"
  //       from_port                = 0
  //       to_port                  = 0
  //       protocol                 = "-1"
  //       source_security_group_id = "sg-0b7ce82bc0d7a3b7e"
  //     }
  //   }
  //   cluster_security_group_additional_rules = {
  //     AllowNLB = {
  //       type                     = "ingress"
  //       description              = "Allow NLB SG"
  //       from_port                = 0
  //       to_port                  = 0
  //       protocol                 = "-1"
  //       source_security_group_id = "sg-0b7ce82bc0d7a3b7e"
  //     }
  //   }

  // argocd_controller_role_arn = [
  //   "arn:aws-us-gov:iam::949744774897:role/argocd-application-controller-master"
  // ]
}
dependency "vpc" {
  config_path = "../vpc"
}
