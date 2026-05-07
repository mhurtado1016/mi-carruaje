# RouteTrack — Script de ejecucion
$env:ANDROID_HOME     = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:JAVA_HOME        = "C:\Program Files\Microsoft\jdk-17.0.18.8-hotspot"
$env:PATH             = "$env:JAVA_HOME\bin;" + [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

$flutter = "C:\Users\Asus\.puro\envs\stable\flutter\bin\flutter.bat"

# Mostrar dispositivos disponibles
Write-Host "`nDispositivos disponibles:" -ForegroundColor Cyan
& $flutter devices

Write-Host "`nIniciando app en modo debug..." -ForegroundColor Green
& $flutter run `
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1 `
  --dart-define=GPS_INTERVAL_MS=8000
