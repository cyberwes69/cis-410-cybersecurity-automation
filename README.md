# CIS 410 — Week 7 Code Package

## Directory Structure

```
.github/
└── workflows/
    └── terraform-plan.yml          ← OIDC GitHub Actions workflow

terraform/
└── week7/
    ├── main.tf                     ← GCS backend + module call
    ├── variables.tf                ← root input variable declarations
    ├── outputs.tf                  ← surfaces module outputs
    ├── terraform.tfvars.example    ← copy → terraform.tfvars and fill in values
    └── modules/
        └── networking/
            ├── main.tf             ← VPC + subnet + 3 firewall rules
            ├── variables.tf        ← module input variable declarations
            └── outputs.tf          ← vpc_name, vpc_id, subnet outputs
```

## Before You Start

Complete Activity 1 in the lab guide first:
1. Create the Workload Identity Pool and Provider
2. Create the service account with IAM roles
3. Add GitHub Variables: WIF_PROVIDER, SA_EMAIL, TF_VAR_PROJECT_ID, TF_VAR_MY_IP_CIDR

## Quick Start

```bash
# 1. Copy into your repo
cp -r terraform/ ~/cis-410-cybersecurity-automation/
cp -r .github/  ~/cis-410-cybersecurity-automation/

# 2. Set your values
cd ~/cis-410-cybersecurity-automation/terraform/week7
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — replace all placeholder values

# 3. Update the backend bucket name in main.tf
# Find: bucket = "cis410-yourname-xxxx-tfstate"
# Replace with your actual GCS bucket name from Week 6

# 4. Run the Terraform workflow
terraform init    # connects to GCS backend, initializes the module
terraform plan    # should show: 5 to add
terraform apply   # type yes — creates VPC, subnet, 3 firewall rules

# 5. Commit (NOT terraform.tfvars or terraform.tfstate)
git add terraform/week7/main.tf
git add terraform/week7/variables.tf
git add terraform/week7/outputs.tf
git add terraform/week7/modules/
git add terraform/week7/.terraform.lock.hcl
git add .github/workflows/terraform-plan.yml
git commit -m "Week 7: OIDC + VPC networking module + GCS remote state"
git push origin main
# Pushing triggers the Terraform Plan workflow in GitHub Actions
```

## What Gets Created

| Resource | Name in GCP | Purpose |
|---|---|---|
| VPC Network | cis410-vpc | Private cloud network |
| Subnet | cis410-vpc-public | Application workloads (10.0.1.0/24) |
| Firewall — SSH | cis410-vpc-allow-ssh | SSH from your IP only |
| Firewall — HTTP | cis410-vpc-allow-http | Web traffic (ports 80, 8080) |
| Firewall — Deny | cis410-vpc-deny-ingress | Explicit deny-all fallback |

## If You Destroy the Buckets

If the GCS tfstate bucket is accidentally destroyed:

```bash
# Recreate buckets from Week 6 code
cd terraform/week6
terraform apply

# Then rebuild Week 7 infrastructure
cd ../week7
terraform apply
```

## GitHub Variables Required

| Variable | Value |
|---|---|
| WIF_PROVIDER | Full Workload Identity Provider path |
| SA_EMAIL | cis410-deploy-sa@PROJECT_ID.iam.gserviceaccount.com |
| TF_VAR_PROJECT_ID | Your GCP project ID |
| TF_VAR_MY_IP_CIDR | Your public IP with /32 |

## Common Error — 403 on terraform init

If you see:
```
Error 403: cis410-deploy-sa does not have storage.objects.list access
```

Run this to grant bucket-level access:
```bash
gcloud storage buckets add-iam-policy-binding gs://cis410-yourname-tfstate \
  --member="serviceAccount:cis410-deploy-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
```

Then retry `terraform init`. This happens because GCS uniform bucket-level access
evaluates bucket-level IAM separately from project-level IAM.
