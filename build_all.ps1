# build_all.ps1 - Allin1 Super App
Set-Location "C:\Projects\all in one"
$env:PATH = "C:\Program Files\nodejs;" + $env:PATH
$FIREBASE = "C:\Users\nijja\AppData\Roaming\npm\firebase.cmd"
Write-Host "=== ALLIN1 FULL BUILD ===" -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "[2/6] CUSTOMER" -ForegroundColor Green
flutter build web --release --target=lib/main_customer.dart
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED" -ForegroundColor Red; exit 1 }
if (Test-Path "build\customer") { Remove-Item "build\customer" -Recurse -Force }
Copy-Item "build\web" "build\customer" -Recurse -Force
$m = Get-Content "build\customer\manifest.json" -Raw
$m = $m -replace '"name":\s*"[^"]*"', '"name": "Allin1 - Order and Ride"'
$m = $m -replace '"short_name":\s*"[^"]*"', '"short_name": "Allin1"'
$m | Set-Content "build\customer\manifest.json"
Write-Host "CUSTOMER OK" -ForegroundColor Green

Write-Host "[3/6] HERO" -ForegroundColor Blue
flutter build web --release --target=lib/main_captain.dart
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED" -ForegroundColor Red; exit 1 }
if (Test-Path "build\captain") { Remove-Item "build\captain" -Recurse -Force }
Copy-Item "build\web" "build\captain" -Recurse -Force
$m = Get-Content "build\captain\manifest.json" -Raw
$m = $m -replace '"name":\s*"[^"]*"', '"name": "Allin1 Hero"'
$m = $m -replace '"short_name":\s*"[^"]*"', '"short_name": "Hero"'
$m | Set-Content "build\captain\manifest.json"
Write-Host "HERO OK" -ForegroundColor Blue

Write-Host "[4/6] GROW" -ForegroundColor Magenta
flutter build web --release --target=lib/main_seller.dart
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED" -ForegroundColor Red; exit 1 }
if (Test-Path "build\seller") { Remove-Item "build\seller" -Recurse -Force }
Copy-Item "build\web" "build\seller" -Recurse -Force
$m = Get-Content "build\seller\manifest.json" -Raw
$m = $m -replace '"name":\s*"[^"]*"', '"name": "Allin1 Grow"'
$m = $m -replace '"short_name":\s*"[^"]*"', '"short_name": "Grow"'
$m | Set-Content "build\seller\manifest.json"
Write-Host "GROW OK" -ForegroundColor Magenta

Write-Host "[5/6] HQ" -ForegroundColor Red
flutter build web --release --target=lib/main_admin.dart
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED" -ForegroundColor Red; exit 1 }
if (Test-Path "build\admin") { Remove-Item "build\admin" -Recurse -Force }
Copy-Item "build\web" "build\admin" -Recurse -Force
$m = Get-Content "build\admin\manifest.json" -Raw
$m = $m -replace '"name":\s*"[^"]*"', '"name": "Allin1 HQ"'
$m = $m -replace '"short_name":\s*"[^"]*"', '"short_name": "HQ"'
$m | Set-Content "build\admin\manifest.json"
Write-Host "HQ OK" -ForegroundColor Red

Write-Host "[6/6] Deploying..." -ForegroundColor Cyan
& $FIREBASE deploy --only hosting --project erode-super-app

Write-Host "Customer -> https://my-allin1.web.app"   -ForegroundColor Green
Write-Host "Hero     -> https://hero-allin1.web.app" -ForegroundColor Blue
Write-Host "Seller   -> https://grow-allin1.web.app" -ForegroundColor Magenta
Write-Host "Admin    -> https://hq-allin1.web.app"   -ForegroundColor Red
