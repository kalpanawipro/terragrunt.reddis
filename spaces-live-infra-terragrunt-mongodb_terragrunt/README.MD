## Prerequisites:

To provision the resources, below are the prerequisites are required.

1.  AWS cli version 2 installed
    https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

2.  Terraform
    https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform

3.  Terragrunt
    https://terragrunt.gruntwork.io/docs/getting-started/install/


# Terraform Modules

Terraform modules can be used as containers for multiple resources that are used together. A module consists of a collection of .tf files kept together in a directory.
Modules are the main way to package and reuse resource configurations with Terraform.


# Architecure review

For the purpose of deploying the complete EKS stack in AWS, we are maintaing two repositories mentioned below for the following reasons :-

1. Terraform Release modules repo - https://wwwin-github.cisco.com/DNASpaces/spaces-terraform-modules.git
   In this repo we are mainting the business logic of the infra creation. We are trying to keep the logic separated from the configurations and make these modules reusable across organisation. These modules will be referenced as source in the terragrunt code. We will be creating releases for modules in the pipeline.

2. Terragrunt repo as deployment pipeline - https://wwwin-github.cisco.com/DNASpaces/spaces-live-infra-terragrunt.git
   In this repo, we have the configurations to be used for the modules created earlier. This repo will act as a deployment pipeline to deploy the actual terraform resources in AWS cloud.

Now, in the terragrunt repo, we have made use of YAML based configuration files to set the values for variables demanded by terraform modules.

# Jenkins Pipeline for Terraform Infrastructure

This Jenkins pipeline is designed to automate the process of code validation and infrastructure deployment using Terraform. It is triggered by GitHub Merge Requests and consists of two stages:

1. **Code Validation Stage**
   - TFSec Check: Validates the Terraform code using [TFSec](https://github.com/tfsec/tfsec).
   - TFLint Check: Performs linting of Terraform code using [TFLint](https://github.com/terraform-linters/tflint).
   - Update Status: Updates the status of the Merge Request on GitHub with the results of TFSec and TFLint checks.

2. **Infrastructure Deployment Stages**
   - terragrunt init: Initializes Terragrunt for the specified environment.
   - terragrunt validate: Validates the Terraform configuration using Terragrunt.
   - terragrunt plan: Generates a Terraform plan using Terragrunt.
   - Manual Approval (for 'main' branch only): Requires manual approval before proceeding further.
   - terragrunt apply (for 'main' branch only): Applies the Terragrunt changes if the branch is 'main'.

**Note:** The pipeline is designed to be triggered by GitHub Webhooks, specifically when a Merge Request is received. It ensures that changes to multiple environments (e.g., dev and staging,pre-prod) are not deployed simultaneously, avoiding potential conflicts.

## Prerequisites
Before using this pipeline, ensure you have the following:

- Jenkins server set up and running.
- Jenkins plugins installed for GitHub integration and Terraform support.
- Terragrunt and Terraform installed on the Jenkins agent.
- TFSec and TFLint installed on the Jenkins agent.
- GitHub Webhooks configured to trigger Jenkins pipelines on Merge Request events.

## Usage
1. Create a PR in the terragrunt module repo(https://wwwin-github.cisco.com/DNASpaces/spaces-live-infra-terragrunt)
2. If the PR is raised, the pipeline(  dnaspace-aws-infra-terragrunt-pipeline  ) will run and update the status to Github
3. If the MR is raised in the main branch, then the Pipeline(dnaspace-aws-infra-terragrunt-pipeline ) will trigger.
4. The pipeline will perform a terragrunt init, terragrunt validate, terragrunt plan.
5. A Manual approval will be required to perform a terragrunt approval
6. The only action required from user is a PR(Pull Request) on the specific branch(feature-01/feature-02 ), MR(Approving a Merge Request on Main Branch) and Manual Approval from the user.

## GitHub Configuration
Ensure the following GitHub settings are in place:

1. Webhook on GitHub repository to send Merge Request events to the Jenkins server.
2. Set up the webhook payload to include the necessary details required for Jenkins to identify the merge request and repository. This is done using the plugin of Jenkins with Github.

## Pipeline Behavior
The pipeline flow is like :-

- The pipeline will be triggered automatically when a Merge Request is opened or updated on GitHub.In a merge requests-detect directory or file changes in single environment -> terragrunt init on changed module folders -> terragrunt plan on changed module folders
- It will first perform code validation using TFSec and TFLint and update the GitHub status with the results.
- If the Merge Request is approved and the branch is the 'main' branch, it will wait for manual approval before proceeding to the Terraform deployment stage.When merge to main branch ,detect directory or file changes in single environment -> terragrunt init on changed module folders -> terragrunt plan on changed module folders -> terragrunt apply on changed module folders.
- If all stages are successful, it will trigger a Terragrunt apply to deploy the infrastructure.
- The pipeline will ensure that only one environment's changes are deployed at a time to prevent conflicts.
- In case of changes to multiple environments, the pipeline will be aborted to avoid concurrent deployments.

Please refer to the Jenkins documentation for more information on setting up Jenkins pipelines and integrating with GitHub.

