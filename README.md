# Data Platform Infrastructure

Terraform and config-as-code for the data engineering platform on GCP.
Manages Cloud Composer (Airflow), BigQuery datasets, IAM, and monitoring.

## What lives here

| Folder       | Contents                                              |
|--------------|-------------------------------------------------------|
| `/terraform` | GCP infrastructure as Terraform modules               |
| `/iam`       | Service account definitions and IAM bindings          |
| `/monitoring`| Datadog dashboard and alert configs                   |
| `/runbooks`  | Operational runbooks for on-call engineers            |

## Environments

| Environment | GCP Project         | Branch  | Deploy trigger       |
|-------------|---------------------|---------|----------------------|
| Production  | my-company-prod     | main    | CI/CD on PR merge    |
| Staging     | my-company-staging  | staging | CI/CD on PR merge    |
| Dev         | my-company-dev      | develop | Manual / local       |

## On-call Contacts

| Role                  | Name          | Contact                     |
|-----------------------|---------------|-----------------------------|
| Platform lead         | Alex Rivera   | alex@company.com (primary)  |
| Data engineering lead | Sarah Chen    | sarah@company.com (secondary)|
| GCP account manager   | GCP Support   | vendor-support@google.com   |
| PagerDuty escalation  | On-call rota  | #data-alerts Slack channel  |

## Deployment

```bash
cd terraform/
terraform init
terraform plan  -var-file=envs/prod.tfvars
terraform apply -var-file=envs/prod.tfvars
```

CI/CD runs this automatically on merge to `main` via GitHub Actions.

## Known Issues

- **Composer 2.7 upgrade blocked** — Terraform hashicorp/google provider v5.x bug prevents
  upgrading Cloud Composer from 2.6 to 2.7. Staying on provider v4.x until resolved. (Issue #1)

- **BigQuery slot resize is manual** — Month-end Finance reporting requires manually increasing
  BigQuery slots from 500 to 1000. Should be automated. (Issue #2)

## Runbooks

- [BigQuery slot resize (month-end)](runbooks/bigquery-slot-resize.md)
- [Cloud Composer issues](runbooks/composer-issues.md)
