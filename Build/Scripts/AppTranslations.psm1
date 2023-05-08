<#
.SYNOPSIS
    Restores translations from an app.
.Description
    This function restores translations for an app.
    All available translations in the translation package will be restored in a 'Translations' folder in the app project folder.
.Parameter AppProjectFolder
    The path to the app project folder
#>
function Restore-TranslationsForApp {
    param (
        [Parameter(Mandatory=$true)]
        [string] $AppProjectFolder
    )
    # Translations need to be restored in the Translations folder in the app folder
    $appTranslationsFolder = Join-Path $AppProjectFolder "Translations"
    $appName = (Get-ChildItem -Path $AppProjectFolder -Filter "app.json" | Get-Content | ConvertFrom-Json).name
   
    Write-Host "Restoring translations for app $appName in $appTranslationsFolder"

    Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1 -DisableNameChecking
    $translationsOutputFolder = Join-Path (Get-BaseFolder) "out/translations/"
    $translationPackagePath = Install-PackageFromConfig -PackageName "Microsoft.Dynamics.BusinessCentral.Translations" -OutputPath $translationsOutputFolder
    $tranlationsPath = Join-Path $translationPackagePath "Translations"

    $translationsFound = $false
    
    # Copy the translations from the package to the app folder
    Get-ChildItem $tranlationsPath -Filter *-* -Directory | ForEach-Object {
        $localeFolder = $_.FullName
        $locale = $_.Name
        
        # Translations are located in the ExtensionsV2 folder
        $translationFilePath = Join-Path $localeFolder "ExtensionsV2/$appName.$locale.xlf" 
        if(Test-Path $translationFilePath) {
            Write-Host "Using translation for $appName in $locale"
            $translationsFound = $true

            Copy-Item -Path $translationFilePath -Destination $appTranslationsFolder -Force | Out-Null
        }
    }

    if (-not $translationsFound) {
        Write-Host "No translations found for $appName"
    }
}

Export-ModuleMember -Function *-*
