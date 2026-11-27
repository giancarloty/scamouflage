$ErrorActionPreference = 'Stop'
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Install Flutter and add it to PATH first.'
}
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }
Write-Host 'Setup complete. Run flutter run -d chrome to start the app.'
