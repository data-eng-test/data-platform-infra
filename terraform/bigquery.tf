# terraform/bigquery.tf
# BigQuery dataset definitions for the data platform.
# All datasets are in us-central1 for co-location with Composer.

resource "google_bigquery_dataset" "raw" {
  dataset_id    = "raw"
  project       = var.project_id
  location      = "US"
  friendly_name = "Raw — Landing Zone"
  description   = "Untransformed data landed by ingest scripts. Do not query directly — use finops or staging datasets."

  access {
    role          = "WRITER"
    user_by_email = google_service_account.finops_pipeline_sa.email
  }
  access {
    role          = "READER"
    special_group = "projectOwners"
  }

  default_table_expiration_ms    = null  # no expiration on raw tables
  delete_contents_on_destroy     = false
}

resource "google_bigquery_dataset" "finops" {
  dataset_id    = "finops"
  project       = var.project_id
  location      = "US"
  friendly_name = "FinOps — Curated Cost Data"
  description   = "Business-ready cloud cost data. Powers the executive FinOps Looker dashboard."

  access {
    role          = "WRITER"
    user_by_email = google_service_account.finops_pipeline_sa.email
  }
  access {
    role          = "READER"
    iam_member    = "group:finance-team@company.com"
  }
  access {
    role          = "READER"
    iam_member    = "group:data-leads@company.com"
  }

  default_table_expiration_ms = null
  delete_contents_on_destroy  = false
}

resource "google_bigquery_dataset" "sandbox" {
  dataset_id    = "_sandbox"
  project       = var.project_id
  location      = "US"
  friendly_name = "Sandbox — Dev / Test"
  description   = "Developer sandbox. NOT production. Tables expire after 30 days."

  access {
    role          = "OWNER"
    iam_member    = "group:data-engineering@company.com"
  }

  default_table_expiration_ms = 2592000000  # 30 days
  delete_contents_on_destroy  = true
}

# BigQuery slot reservation — manually resized at month-end
# TODO: Automate via Cloud Function (see GitHub issue #2)
resource "google_bigquery_capacity_commitment" "finops_slots" {
  project       = var.project_id
  location      = "US"
  slot_count    = 500
  plan          = "FLEX"
  renewal_plan  = "FLEX"
}
