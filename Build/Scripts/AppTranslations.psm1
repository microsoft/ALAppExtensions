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
    Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1 -DisableNameChecking

    # Translations need to be restored in the Translations folder in the app folder
    $appTranslationsFolder = Join-Path $AppProjectFolder "Translations"
    New-Directory -Path "$appTranslationsFolder" -ForceEmpty

    $appName = (Get-ChildItem -Path $AppProjectFolder -Filter "app.json" | Get-Content | ConvertFrom-Json).name

    Write-Host "Restoring translations for app $appName in $appTranslationsFolder"

    $translationsOutputFolder = Join-Path (Get-BaseFolder) "out/translations/"
    $translationPackagePath = Install-PackageFromConfig -PackageName "Microsoft.Dynamics.BusinessCentral.Translations" -OutputPath $translationsOutputFolder
    $tranlationsPath = Join-Path $translationPackagePath "Translations"

    $translationsFound = $false

    # Copy the translations from the package to the app folder
    $translationFolders = Get-ChildItem $tranlationsPath -Filter *-* -Directory

    foreach($translationFolder in $translationFolders) {
        $localeFolder = $translationFolder.FullName
        $locale = $translationFolder.Name

        # Translations are located in the ExtensionsV2 folder
        $translationFilePath = Join-Path $localeFolder "ExtensionsV2/$appName.$locale.xlf"
        if(Test-Path $translationFilePath) {
            Write-Host "Using translation for $appName in locale $locale."
            $translationsFound = $true

            Copy-Item -Path $translationFilePath -Destination $appTranslationsFolder -Force | Out-Null
        }
    }

    if (-not $translationsFound) {
        Write-Host "No translations found for $appName"
    }
}

Export-ModuleMember -Function *-*
