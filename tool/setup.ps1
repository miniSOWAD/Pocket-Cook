$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Install Flutter and add flutter/bin to PATH first."
}
if (-not (Test-Path "android") -or -not (Test-Path "ios") -or -not (Test-Path "web")) {
    Write-Host "Generating missing platform projects using the existing Firebase technical app identifier..."
    flutter create --project-name recipe_app --org com.trendintools "--platforms=android,ios,web" --no-pub .
    if ($LASTEXITCODE -ne 0) { throw "Flutter project generation failed." }
} else {
    Write-Host "Platform projects already exist; keeping their Firebase application identifiers unchanged."
}
dart tool/configure_platforms.dart
if ($LASTEXITCODE -ne 0) { throw "Platform configuration failed." }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "Dependency resolution failed." }
Write-Host "Setup complete. Try: flutter run -d chrome"
