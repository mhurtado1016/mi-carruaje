# RouteTrack Backend

$envFile = Join-Path $PSScriptRoot ".env"
$envExample = Join-Path $PSScriptRoot ".env.example"

if (-not (Test-Path $envFile)) {
  if (Test-Path $envExample) {
    Copy-Item $envExample $envFile
    Write-Warning ".env file not found. Copied from .env.example — please update it with your real credentials before running."
  } else {
    Write-Error ".env file not found and no .env.example to copy from. Aborting."
    exit 1
  }
}

$env:NODE_ENV = "development"
node server.js
