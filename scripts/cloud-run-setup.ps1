param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId,

  [string]$Region = "us-central1",
  [string]$Repository = "gconnect-mcp-all-v1",
  [string]$FirestoreDatabaseId = "gconnect-mcp-all-v1"
)

$ErrorActionPreference = "Stop"

if ($FirestoreDatabaseId -eq "(default)" -or $FirestoreDatabaseId -eq "default" -or $FirestoreDatabaseId -eq "ga4-mcp-v3") {
  throw "FIRESTORE_DATABASE_ID must be gconnect-mcp-all-v1. Do not use (default) or ga4-mcp-v3."
}

Write-Host "Setting project $ProjectId"
gcloud config set project $ProjectId
if ($LASTEXITCODE -ne 0) { throw "gcloud is not available or the project ID is wrong." }

$apis = @(
  "run.googleapis.com",
  "cloudbuild.googleapis.com",
  "artifactregistry.googleapis.com",
  "analyticsdata.googleapis.com",
  "analyticsadmin.googleapis.com",
  "googleads.googleapis.com",
  "firestore.googleapis.com",
  "secretmanager.googleapis.com"
)

foreach ($api in $apis) {
  Write-Host "Enabling $api"
  gcloud services enable $api --project $ProjectId
}

$existing = gcloud artifacts repositories describe $Repository `
  --location $Region `
  --project $ProjectId `
  --format "value(name)" 2>$null

if (-not $existing) {
  Write-Host "Creating Artifact Registry repository $Repository in $Region"
  gcloud artifacts repositories create $Repository `
    --repository-format=docker `
    --location $Region `
    --description "gconnect-mcp-all-v1 Cloud Run images" `
    --project $ProjectId
}

$existingDb = gcloud firestore databases describe --database=$FirestoreDatabaseId --project $ProjectId --format "value(name)" 2>$null
if (-not $existingDb) {
  Write-Host "Creating named Firestore database $FirestoreDatabaseId (not default, not V3)"
  gcloud firestore databases create `
    --database=$FirestoreDatabaseId `
    --location=$Region `
    --type=firestore-native `
    --project $ProjectId
}

Write-Host "Google Cloud is ready. Next: .\scripts\cloud-run-deploy.ps1 -ProjectId $ProjectId"
