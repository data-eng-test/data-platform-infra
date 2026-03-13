# Runbook: BigQuery Slot Resize (Month-End)

**Trigger:** Finance team reports slow Looker dashboard loads, typically on the 1st–3rd of each month.

**Owner:** On-call data engineer
**Escalation:** Alex Rivera (alex@company.com)
**Time required:** ~10 minutes active, 30 minutes monitoring

---

## Background

The `finops` BigQuery dataset uses FLEX slot reservations (500 slots by default).
At month-end, Finance runs large date-range queries across the full billing history,
which exhausts the slot allocation and causes query queuing.

This is a manual process until automation is in place — see GitHub issue #2.

---

## Steps

### 1. Confirm the problem
- Go to GCP Console → BigQuery → Job History
- Look for jobs with status `QUEUED` lasting more than 2 minutes
- Confirm they are from the `finops` dataset or `finance-team@company.com` accounts

### 2. Increase slot reservation
- GCP Console → BigQuery → Capacity Management → Reservations
- Find reservation: `finops-prod`
- Click **Edit** → change slot count from **500 → 1000**
- Click Save

### 3. Monitor
- Refresh Job History — queued jobs should start running within 2 minutes
- Slack message the Finance team in #finops-support: *"Slot capacity increased, dashboards should be responsive now"*
- Monitor for 30 minutes

### 4. Scale back down
- Typically on the 3rd of the month once Finance confirms reporting is complete
- Repeat step 2 but set slots back to **1000 → 500**
- Notify Finance: *"Slot capacity returned to normal"*

---

## If slots cannot be increased

GCP FLEX slot quota may be exhausted at the project level.

1. Check current quota: GCP Console → IAM & Admin → Quotas → search "BigQuery Slots"
2. If at limit, submit a quota increase request (takes 24–48 hours)
3. While waiting — advise Finance to run smaller date-range queries (monthly not yearly)
4. Escalate to Alex Rivera immediately if reports are business-critical

---

## Permanent fix

Automate this with a Cloud Function triggered by a Pub/Sub schedule.
Tracked in GitHub issue #2: "Automate month-end BigQuery slot resize"
