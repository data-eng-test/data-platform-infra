# iam/service-accounts.tf
# Service account definitions for the data platform.
# Principle of least privilege — each SA has only the permissions it needs.

# ── FinOps Pipeline SA ────────────────────────────────────────────────────────
# Used by: finops_daily Airflow DAG, ingest scripts, dbt
resource "google_service_account" "finops_pipeline_sa" {
  account_id   = "finops-pipeline"
  display_name = "FinOps Pipeline"
  description  = "Service account for the finops-pipeline repo. Reads AWS/GCP billing, writes to BQ raw + finops datasets."
  project      = var.project_id
}

resource "google_project_iam_member" "finops_bq_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.finops_pipeline_sa.email}"
}

resource "google_project_iam_member" "finops_bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.finops_pipeline_sa.email}"
}

# ── Cloud Composer SA ─────────────────────────────────────────────────────────
# Used by: Cloud Composer environment nodes
resource "google_service_account" "composer_sa" {
  account_id   = "composer-worker"
  display_name = "Cloud Composer Worker"
  description  = "Service account for Cloud Composer worker nodes."
  project      = var.project_id
}

resource "google_project_iam_member" "composer_worker_role" {
  project = var.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

# ── dbt SA ────────────────────────────────────────────────────────────────────
# Used by: dbt runs (both local dev and Airflow)
resource "google_service_account" "dbt_sa" {
  account_id   = "dbt-runner"
  display_name = "dbt Runner"
  description  = "Service account for dbt model runs. Read raw, write to staging and finops datasets."
  project      = var.project_id
}
