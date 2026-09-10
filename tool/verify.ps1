$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
dart format lib test integration_test tool
if ($LASTEXITCODE -ne 0) { throw "Formatting failed." }
flutter analyze
if ($LASTEXITCODE -ne 0) { throw "Static analysis failed." }
flutter test
if ($LASTEXITCODE -ne 0) { throw "Flutter tests failed." }
flutter build web --release
if ($LASTEXITCODE -ne 0) { throw "Web build failed." }
if (Get-Command node -ErrorAction SilentlyContinue) {
    node firebase/scripts/validate_seed.mjs
    if ($LASTEXITCODE -ne 0) { throw "Seed validation failed." }
    node --test firebase/tests/seed_validation.test.mjs
    if ($LASTEXITCODE -ne 0) { throw "Seed validation tests failed." }
}
