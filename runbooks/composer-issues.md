# Runbook: Cloud Composer (Airflow) Environment Issues

**Owner:** On-call data engineer
**Escalation:** Alex Rivera (alex@company.com) → GCP Support

---

## Composer is not reachable / Airflow UI returns 502

1. GCP Console → Cloud Composer → Environments → `data-platform-prod`
2. Check environment status — should show **Running** (green)
3. If **Updating** — wait, a deployment may be in progress (check Terraform CI in GitHub Actions)
4. If **Error** — click View Logs → look for OOM or node startup failures
5. If nodes are unhealthy: GCP Console → Kubernetes Engine → Clusters → `data-platform-prod` → Nodes tab → check for NotReady nodes

**Common fix:** Delete the unhealthy node. GKE will automatically recreate it.

---

## DAG not appearing in Airflow UI

DAGs are synced from the `dags/` folder in the `finops-pipeline` repo via Cloud Storage.

1. Check the DAG file was merged to `main` and CI passed
2. GCP Console → Cloud Storage → find the Composer bucket (name starts with `us-central1-data-platform`)
3. Navigate to `/dags/` — confirm your file is there
4. If missing: manually upload from your local clone: `gsutil cp dags/your_dag.py gs://[bucket]/dags/`
5. Airflow picks up new DAGs within 60 seconds (controlled by `scheduler-min_file_process_interval`)

---

## Airflow task stuck in "running" for > 2 hours

1. Airflow UI → DAG → Task Instance → Log → check if genuinely running or hung
2. If log shows no activity for > 30 minutes → mark as failed and re-run
3. If the worker pod is OOMKilled: check GKE pod logs and consider increasing worker memory in `terraform/composer.tf`

---

## Environment upgrade procedure

**Current version:** composer-2.6.6-airflow-2.7.3
**Blocked upgrade:** composer-2.7.x blocked by Terraform provider bug (see GitHub issue #1)

When the provider bug is resolved:
1. Update `image_version` in `terraform/composer.tf`
2. Run `terraform plan` — review changes carefully (Composer upgrades replace the environment)
3. Schedule upgrade during low-traffic window (Saturday 08:00–12:00 UTC)
4. Notify the data engineering team in #data-eng Slack at least 48 hours in advance
5. Keep the old environment until all DAGs confirmed healthy on new version
