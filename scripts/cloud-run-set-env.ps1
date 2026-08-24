param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId,

  [Parameter(Mandatory = $true)]
  [string]$AppBaseUrl,

  [Parameter(Mandatory = $true)]
  [string]$GoogleClientId,

  [Parameter(Mandatory = $true)]
  [string]$GoogleClientSecret,

  [Parameter(Mandatory = $true)]
  [string]$McpTokenSecret,

  [Parameter(Mandatory = $true)]
  [string]$OauthStateSecret,

  [Parameter(Mandatory = $true)]
  [string]$TokenEncryptionKey,

  [Parameter(Mandatory = $true)]
  [string]$GoogleAdsDeveloperToken,

  [string]$FirestoreProjectId = "",
  [string]$FirestoreDatabaseId = "gconnect-mcp-all-v1",
  [string]$Region = "us-central1",
  [string]$Service = "gconnect-mcp-all-v1"
)

$ErrorActionPreference = "Stop"

if ($FirestoreDatabaseId -ne "gconnect-mcp-all-v1") {
  throw "FIRESTORE_DATABASE_ID must be gconnect-mcp-all-v1. Do not use (default) or ga4-mcp-v3."
}

$base = $AppBaseUrl.TrimEnd("/")
$redirect = "$base/oauth/google/callback"
$firestoreProject = if ($FirestoreProjectId) { $FirestoreProjectId } else { $ProjectId }

$pairs = @(
  "APP_BASE_URL=$base",
  "GOOGLE_CLIENT_ID=$GoogleClientId",
  "GOOGLE_CLIENT_SECRET=$GoogleClientSecret",
  "GOOGLE_REDIRECT_URI=$redirect",
  "MCP_TOKEN_SECRET=$McpTokenSecret",
  "OAUTH_STATE_SECRET=$OauthStateSecret",
  "TOKEN_ENCRYPTION_KEY=$TokenEncryptionKey",
  "GOOGLE_ADS_DEVELOPER_TOKEN=$GoogleAdsDeveloperToken",
  "FIRESTORE_PROJECT_ID=$firestoreProject",
  "FIRESTORE_DATABASE_ID=$FirestoreDatabaseId"
)

Write-Host "Updating Cloud Run environment for $Service (values are not printed)"
gcloud run services update $Service `
  --region $Region `
  --project $ProjectId `
  --update-env-vars ($pairs -join ",")

Write-Host "Environment updated. Revision will start automatically."
Write-Host "Add this Google OAuth redirect URI if you have not already:"
Write-Host "  $redirect"
