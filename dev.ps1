# RouteTrack - Ambiente de desarrollo completo
# Uso: .\dev.ps1

$ROOT        = $PSScriptRoot
$BACKEND     = "$ROOT\backend"
$FLUTTER_DIR = "$ROOT\routetrack"
$FLUTTER_BIN = "C:\Users\Asus\.puro\envs\stable\flutter\bin\flutter.bat"

$env:ANDROID_HOME     = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:JAVA_HOME        = "C:\Program Files\Microsoft\jdk-17.0.18.8-hotspot"
$env:PATH             = "$env:JAVA_HOME\bin;" + [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

$ADB      = "$env:ANDROID_HOME\platform-tools\adb.exe"
$EMULATOR = "$env:ANDROID_HOME\emulator\emulator.exe"
$AVD      = "RouteTrack_Pixel6"

# ── 1. BACKEND ────────────────────────────────────────────────────────────────
Write-Host "`n[1/3] Iniciando backend (puerto 3000)..." -ForegroundColor Cyan

if (-not (Test-Path "$BACKEND\.env")) {
    Copy-Item "$BACKEND\.env.example" "$BACKEND\.env"
    Write-Host "      .env copiado - configura SUPABASE_URL y SUPABASE_SERVICE_KEY" -ForegroundColor Yellow
}

$backendProc = Start-Process -FilePath "node" -ArgumentList "server.js" `
    -WorkingDirectory $BACKEND -PassThru -WindowStyle Normal

Start-Sleep -Seconds 2

if ($backendProc.HasExited) {
    Write-Host "      Backend cerro - revisa $BACKEND\.env" -ForegroundColor Yellow
} else {
    Write-Host "      Backend OK (PID $($backendProc.Id))" -ForegroundColor Green
}

# ── 2. EMULADOR ───────────────────────────────────────────────────────────────
Write-Host "`n[2/3] Verificando emulador..." -ForegroundColor Cyan

$devices = & $ADB devices
$running = $devices | Select-String "emulator"

if ($running) {
    Write-Host "      Emulador ya esta corriendo" -ForegroundColor Green
} else {
    Write-Host "      Iniciando emulador $AVD..." -ForegroundColor White

    Start-Process -FilePath $EMULATOR `
        -ArgumentList "-avd $AVD -no-snapshot-load -no-audio -no-metrics" `
        -WindowStyle Normal

    Write-Host "      Esperando arranque del emulador..." -ForegroundColor White

    $timeout = 120
    $elapsed = 0
    $booted  = $false

    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 4
        $elapsed += 4
        $status = & $ADB shell getprop sys.boot_completed
        Write-Host "      [$elapsed s] boot_completed=$status" -ForegroundColor DarkGray
        if ($status -match "1") {
            $booted = $true
            break
        }
    }

    if ($booted) {
        Write-Host "      Emulador listo" -ForegroundColor Green
    } else {
        Write-Host "      Emulador tardo mas de $timeout s - continua de todos modos" -ForegroundColor Yellow
    }
}

# ── 3. FLUTTER ────────────────────────────────────────────────────────────────
Write-Host "`n[3/3] Lanzando app Flutter..." -ForegroundColor Cyan
Write-Host "      Ctrl+C detiene flutter run (backend y emulador siguen corriendo)" -ForegroundColor DarkGray
Write-Host ""

Set-Location $FLUTTER_DIR
& $FLUTTER_BIN run `
    --device-id emulator-5554 `
    --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1 `
    --dart-define=GPS_INTERVAL_MS=8000
