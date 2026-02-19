# Reset App Data Script for Windows
$appDataPath = "$env:APPDATA\com.qada\fard"

if (Test-Path $appDataPath) {
    Write-Host "Resetting app data in $appDataPath..."
    # Keep the fonts (.ttf) but remove everything else (SharedPreferences and Hive boxes)
    Get-ChildItem -Path $appDataPath -Exclude "*.ttf" | Remove-Item -Recurse -Force
    Write-Host "App data reset complete. You can now test the onboarding again."
} else {
    Write-Host "App data directory not found. The app might not have been run yet or data is already cleared."
}
