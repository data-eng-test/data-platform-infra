# Data Platform Infrastructure

Terraform and config-as-code for the data engineering platform on GCP.
Manages Cloud Composer (Airflow), BigQuery datasets, IAM, and networking.

## What lives here
- `/terraform` — all GCP infrastructure as Terraform modules
- `/iam`        — service account definitions and IAM bindings
- `/monitoring` — Datadog dashboards and alert configs
- `/runbooks`   — operational runbooks for on-call engineers

## Environments
| Environment | GCP Project         | Branch   |
|-------------|---------------------|----------|
| Production  | my-company-prod     | main     |
| Staging     | my-company-staging  | staging  |
| Dev         | my-company-dev      | develop  |

## On-call Contacts
- Platform lead: Alex Rivera (alex@company.com) — primary
- Escalation: Sarah Chen (sarah@company.com) — secondary
- GCP account manager: vendor-support@google.com

## Deployment
```bash
cd terraform/
terraform init
terraform plan -var-file=envs/prod.tfvars
terraform apply
```

## Known Issues
- Cloud Composer upgrade from 2.6 to 2.7 is blocked by a Terraform provider bug
- BigQuery slot reservations need manual resizing at month-end (ticket: INFRA-204)
