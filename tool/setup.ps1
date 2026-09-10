$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Install Flutter and add flutter/bin to PATH first."
}
Write-Host "Generating official Android, iOS, and web platform projects..."
flutter create --project-name recipe_app --org com.trendintools "--platforms=android,ios,web" --no-pub .
if ($LASTEXITCODE -ne 0) { throw "Flutter project generation failed." }
dart tool/configure_platforms.dart
if ($LASTEXITCODE -ne 0) { throw "Platform configuration failed." }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "Dependency resolution failed." }
Write-Host "Setup complete. Try: flutter run -d chrome"
