# Deploying AWS Resources with GitHub Actions and Terraform

This guide explains how to connect GitHub Actions to AWS to deploy this repository's infrastructure with Terraform, without storing long-lived credentials in GitHub.

## Infrastructure as Code Connection

- **Code management:** GitHub.
- **Cloud service:** AWS.
- **Infrastructure as Code (IaC):** Terraform.
- **Automation:** GitHub Actions.
- **Authentication:** OpenID Connect (OIDC).

## How OIDC Works

OpenID Connect is an identity layer built on OAuth 2.0. GitHub Actions obtains an OIDC token for the workflow; AWS validates that token and allows it to assume an IAM role if it meets the trust conditions. This avoids storing AWS access keys as GitHub secrets.

## Configure AWS

1. In AWS IAM, create the GitHub Actions OIDC provider if it does not already exist:
   - Provider URL: `https://token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`
2. Create an IAM role, for example `github-actions`.
3. Configure the role's trust policy to restrict which organization, repository, and branch can assume it.
4. Attach a permissions policy that allows only the AWS actions Terraform needs to manage the resources.

Example trust policy for the `main` branch:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<YOUR_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<YOUR_ORG_OR_USER>/<YOUR_REPO>:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

Replace `<YOUR_ACCOUNT_ID>`, `<YOUR_ORG_OR_USER>`, and `<YOUR_REPO>` with the actual values. The `sub` condition limits access to the specified repository and branch.

## Configure GitHub Actions

Create a workflow at `.github/workflows/<WORKFLOW_NAME>.yml`. The `id-token: write` permission lets GitHub issue an OIDC token; `contents: read` lets the workflow read the repository.

```yaml
name: Terraform

on:
  push:
    branches:
      - main

permissions:
  id-token: write
  contents: read

env:
  AWS_REGION: us-east-1

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::<YOUR_ACCOUNT_ID>:role/<ROLE_FOR_GITHUB>
          aws-region: ${{ env.AWS_REGION }}

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Initialize Terraform
        working-directory: deploy
        run: terraform init

      - name: Plan Terraform
        working-directory: deploy
        run: terraform plan

      - name: Apply Terraform
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        working-directory: deploy
        run: terraform apply -auto-approve
```

Replace `<YOUR_ACCOUNT_ID>` and `<ROLE_FOR_GITHUB>` with your AWS account ID and IAM role name. Make sure the region matches the project configuration.

## Deployment Flow

1. Changes are pushed to the `main` branch.
2. GitHub Actions starts the workflow and requests an OIDC token.
3. AWS validates the token against the trust policy and provides temporary credentials for the role.
4. Terraform initializes the backend, creates a plan, and applies the authorized changes.

Review the role's permissions and the plan before enabling automatic `terraform apply` in a production environment.
