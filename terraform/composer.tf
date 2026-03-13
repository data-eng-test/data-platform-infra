# terraform/composer.tf
# Cloud Composer (managed Airflow) environment for the data platform.
# Owned by: Platform Engineering
# Contact:  Alex Rivera (alex@company.com)
#
# KNOWN ISSUE: Upgrade from composer-2.6 to composer-2.7 is currently blocked
# by a bug in hashicorp/google provider v5.x. Staying on v4.x until resolved.
# See GitHub issue #1 in this repo.

resource "google_composer_environment" "main" {
  name    = "data-platform-${var.environment}"
  region  = var.region
  project = var.project_id

  config {
    node_count = var.environment == "prod" ? 3 : 1

    node_config {
      zone            = "${var.region}-a"
      machine_type    = var.environment == "prod" ? "n1-standard-4" : "n1-standard-2"
      service_account = google_service_account.composer_sa.email
    }

    software_config {
      image_version = "composer-2.6.6-airflow-2.7.3"

      airflow_config_overrides = {
        "core-max_active_runs_per_dag"  = "3"
        "core-dagbag_import_timeout"    = "120"
        "scheduler-min_file_process_interval" = "60"
      }

      env_variables = {
        BQ_PROJECT     = var.project_id
        ENVIRONMENT    = var.environment
        SLACK_WEBHOOK  = var.slack_webhook_url
      }

      pypi_packages = {
        "dbt-core"      = "==1.7.4"
        "dbt-bigquery"  = "==1.7.4"
        "boto3"         = "==1.34.14"
      }
    }

    private_environment_config {
      enable_private_endpoint = var.environment == "prod" ? true : false
    }
  }

  labels = {
    environment = var.environment
    team        = "data-engineering"
    managed-by  = "terraform"
  }
}
