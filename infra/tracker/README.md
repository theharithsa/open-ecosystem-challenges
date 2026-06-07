# Tracker

A Cloud Run service that receives bizevent payloads from challenge Codespaces and forwards them to a Dynatrace tenant.

It validates that every incoming event has `type: offon.challenge`, a known `action`, and all required fields (`adventure.name`, `adventure.level`, `adventure.number`, `adventure.month`, `adventure.year`, `session.id`) before ingesting. Anything else is rejected with a 400.

## Deployment

Deployed manually via the Google Cloud CLI. One-time secret setup:

```sh
echo -n "dt0c01.xxx" | gcloud secrets create offon-challenge-tracker-dt-api-token --data-file=-

PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')
gcloud secrets add-iam-policy-binding offon-challenge-tracker-dt-api-token \
  --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

Deploy:

```sh
gcloud run deploy offon-challenge-tracker \
  --source infra/tracker \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars DT_TENANT_URL=<your-tenant-url> \
  --set-secrets DT_API_TOKEN=offon-challenge-tracker-dt-api-token:latest
```

To update the service, re-run the deploy command.
