# PowerShell script for adding translations

param(
    [Parameter(Mandatory=$true)]
    [string]$Key,
    
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$EnglishTextArray
)

$EnglishText = $EnglishTextArray -join ' '

# Check if key already exists
$files = Get-ChildItem -Path "lib/l10n/app_*.arb"
foreach ($file in $files) {
    $content = Get-Content $file -Raw
    if ($content -match "`"$Key`":") {
        Write-Host "Error: Key '$Key' already exists in one or more translation files" -ForegroundColor Red
        exit 1
    }
}

function Add-Translation {
    param(
        [string]$FilePath,
        [string]$Text,
        [string]$Description
    )
    
    $content = Get-Content $FilePath -Raw
    # Remove closing brace
    $content = $content.TrimEnd()
    if ($content.EndsWith("}")) {
        $content = $content.Substring(0, $content.Length - 1).TrimEnd()
    }
    
    # Add comma if needed
    if (-not $content.EndsWith(",")) {
        $content += ","
    }
    
    # Add new translation
    $content += "`n    `"$Key`": `"$Text`""
    
    if ($Description) {
        $content += ",`n    `"@$Key`": {`n        `"description`": `"$Description`"`n    }"
    }
    
    $content += "`n}"
    
    $content | Out-File -FilePath $FilePath -Encoding utf8 -NoNewline
}

# Add translations
Add-Translation -FilePath "lib/l10n/app_en.arb" -Text $EnglishText -Description "Translation for: $EnglishText"
Add-Translation -FilePath "lib/l10n/app_fi.arb" -Text "<$EnglishText>" -Description ""
Add-Translation -FilePath "lib/l10n/app_sv.arb" -Text "<$EnglishText>" -Description ""

Write-Host "Added translations for '$Key':" -ForegroundColor Green
Write-Host "  English: $EnglishText"
Write-Host "  Finnish: <$EnglishText> (placeholder)"
Write-Host "  Swedish: <$EnglishText> (placeholder)"
Write-Host ""
Write-Host "Don't forget to add proper translations in:" -ForegroundColor Yellow
Write-Host "  - lib/l10n/app_fi.arb"
Write-Host "  - lib/l10n/app_sv.arb"
Write-Host ""
Write-Host "Running flutter gen-l10n..." -ForegroundColor Cyan
flutter gen-l10n
