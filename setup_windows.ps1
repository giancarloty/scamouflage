# Run from the extracted project folder in Windows PowerShell.
$ErrorActionPreference = 'Stop'
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter SDK is not on PATH. Install Flutter, then reopen the terminal.'
}
Write-Host 'Generating official Flutter Android, iOS, and web platform shells...'
flutter create --platforms=android,ios,web --project-name scamouflage .
if ($LASTEXITCODE -ne 0) { throw 'flutter create failed' }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }
flutter analyze
if ($LASTEXITCODE -ne 0) { Write-Warning 'Analyzer found issues. Review output.' }
flutter test
if ($LASTEXITCODE -ne 0) { Write-Warning 'Tests need attention. Review output.' }
Write-Host 'Setup complete. For web: flutter run -d chrome; for Android: flutter run'
Write-Host 'iOS compilation requires macOS with Xcode, even though ios/ was generated.'
