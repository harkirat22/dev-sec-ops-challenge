
# CircleCI Integration with GCP and Falco Deployment on GKE

This repository provides a CircleCI configuration that integrates with Google Cloud Platform (GCP) using Workload Identity Federation. The pipeline performs authentication with GCP, deploys a GKE cluster, and uses Terraform's Helm provider to deploy Falco with custom rules.

## Configuration Overview

- **Orbs**: The configuration uses the `circleci/gcp-cli` orb for GCP operations.
  
- **Commands**:
  - `gcp-oidc-generate-cred-config-file`: Generates a GCP credential configuration file using a CircleCI OIDC token.
  - `gcp-oidc-authenticate`: Authenticates with GCP using the generated credentials file.

- **Jobs**:
  - `gcp-oidc-trust`: Authenticates with GCP.
  - `deploy-gke`: Deploys a GKE cluster using Terraform.
  - `deploy-falco`: Deploys Falco to the GKE cluster using Terraform's Helm provider and triggers a test alert.

- **Workflows**:
  - `main`: Runs the jobs in sequence.

- **Falco Custom Rules**: The configuration includes a custom Falco rule that triggers an alert when a file named `/tmp/hacked` is created. This rule is defined in `rules-custom.yaml` and is applied using the Helm provider in Terraform.

- **Terraform Helm Provider**: The Helm provider for Terraform is used to deploy Falco with custom rules to the GKE cluster. The Helm chart is located in `../../helm/falco-custom` and the custom rules are loaded from `../../helm/falco-custom/rules-custom.yaml`.

## Required Environment Variables for CircleCI:

- `GCP_PROJECT_ID`: The ID of your GCP project.
- `GCP_WIP_ID`: Workload Identity Pool ID.
- `GCP_WIP_PROVIDER_ID`: Workload Identity Pool Provider ID.
- `GCP_SERVICE_ACCOUNT_EMAIL`: Email of the GCP service account used for operations.

## Steps:

1. **Authentication**: Authenticate to GCP using CircleCI's OIDC token and the provided environment variables.
2. **GKE Deployment**: Deploy a GKE cluster using Terraform.
3. **Falco Deployment**: Deploy Falco with custom rules to the GKE cluster using Terraform's Helm provider.

## Usage:

1. Ensure that you've set up Workload Identity Federation in GCP.
2. Populate the required environment variables in CircleCI.
3. Push changes to the repository to trigger the CircleCI pipeline.

## Debugging:

- Check CircleCI logs for errors or warnings.
- Ensure the GCP service account has the necessary permissions.
- If encountering IAM issues, verify that the service account has the necessary roles.
- Check Falco logs in the GKE cluster for alerts or issues related to the custom rules.
