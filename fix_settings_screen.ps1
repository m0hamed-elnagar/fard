# Fix settings_screen.dart by removing leftover code and adding section methods

$file = "lib\features\settings\presentation\screens\settings_screen.dart"
$content = Get-Content $file -Raw

# Find the line with "_buildDataAndLocationSection" and remove everything until "Debug: Widget"
$pattern = '(_buildDataAndLocationSection\(context, state, l10n\),)(.*?)(\/\/ Debug: Widget Refresh Section)'
$replacement = '$1`n                $3'

$content = [regex]::Replace($content, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)

# Read the section methods file
$sections = Get-Content "settings_sections_to_add.txt" -Raw

# Find the position just before the last closing brace of the class
$lastBrace = $content.LastIndexOf('}')
$beforeBrace = $content.Substring(0, $lastBrace)
$afterBrace = $content.Substring($lastBrace)

# Insert the new methods
$content = $beforeBrace + "`n" + $sections + "`n" + $afterBrace

# Write back
Set-Content $file -Value $content -Encoding UTF8

Write-Host "✅ Settings screen updated successfully!"
