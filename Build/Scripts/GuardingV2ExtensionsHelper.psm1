<#
.Synopsis
    Configure breaking changes check
.Description
    Configure breaking changes check by:
    - Restoring the baseline package and placing it in the app symbols folder
    - Generating an AppSourceCop.json with version and name of the extension
.Parameter AppSymbolsFolder
    Local AppSymbols folder
.Parameter AppProjectFolder
    Local AppProject folder
.Parameter BuildMode
    Build mode
#>
function Enable-BreakingChangesCheck {
    Param(
        [Parameter(Mandatory = $true)]
        [string] $AppSymbolsFolder,
        [Parameter(Mandatory = $true)]
        [string] $AppProjectFolder,
        [Parameter(Mandatory = $true)]
        [string] $BuildMode
    )

    # Load the app.json
    $appJsonFilePath = Join-Path $AppProjectFolder "app.json"
    $appJson = Get-Content -Path $appJsonFilePath -Raw | ConvertFrom-Json
    $appName = $appJson.name

    Write-Host "Enabling breaking changes check for app: $appName, build mode: $BuildMode"

    # Restore the baseline package and place it in the app symbols folder
    $baselineFolder =  $AppSymbolsFolder

    switch ($BuildMode) {
        'Clean' {
            Write-Host "Looking for baseline app to use in the baseline folder: $baselineFolder"

            $baselineAppFile = Get-ChildItem -Path $baselineFolder -Filter "$($appName)_clean.app"

            if(-not ($baselineAppFile)) {
                throw "Unable to find baseline app in $baselineFolder"
            }
            $baselineVersion = $appJson.version # Use the version of the current app as the baseline version
        }
        Default {
            $baselineVersion = Restore-BaselinesFromArtifacts -TargetFolder $AppSymbolsFolder -AppName $appName
        }
    }

    if ($baselineVersion) {
        # Generate the app source cop json file
        Update-AppSourceCopVersion -AppProjectFolder $AppProjectFolder -AppName $appName -BaselineVersion $baselineVersion -BuildMode $BuildMode
    }
    else {
        Write-Host "Breaking changes check will not be performed for $appName as no baseline was restored or generated"
    }
}

<#
.Synopsis
    Given an app and a baseline version, it restores the baseline for an app from bcartifacts
.Parameter AppName
    Name of the app
.Parameter TargetFolder
    Folder where to restore the baseline
.Returns
    The version of the baseline that was restored. If no baseline was restored, returns null
#>
function Restore-BaselinesFromArtifacts {
    Param(
        [Parameter(Mandatory = $true)]
        [string] $AppName,
        [Parameter(Mandatory = $true)]
        [string] $TargetFolder
    )
    Import-Module -Name $PSScriptRoot\EnlistmentHelperFunctions.psm1

    $baselinePackage = Get-ConfigValue -Key "AppBaselines-BCArtifacts" -ConfigType Packages
    if (-not $baselinePackage) {
        throw "Unable to find baseline package in Packages.json"
    }

    $baselineVersion = $baselinePackage.Version
    $baselineFolder = Join-Path (Get-BaseFolder) "out/baselineartifacts/$baselineVersion"

    if (-not (Test-Path $baselineFolder)) {
        $baselineURL = Get-BCArtifactUrl -type Sandbox -country W1 -version $baselineVersion

        # TODO: temporary workaround for baselines not being available in bcartifacts
        if(-not $baselineURL) {
            #Fallback to bcinsider
            $baselineURL = Get-BCArtifactUrl -type Sandbox -country W1 -version $baselineVersion -storageAccount bcinsider -accept_insiderEula
        }

        if (-not $baselineURL) {
            throw "Unable to find URL for baseline version $baselineVersion"
        }
        Write-Host "Downloading from $baselineURL to $baselineFolder"
        Download-Artifacts -artifactUrl $baselineURL -basePath $baselineFolder | Out-Null
    }

    $baselineApp = Get-ChildItem -Path "$baselineFolder/sandbox/$baselineVersion/W1/Extensions" -Filter "*_$($AppName)_$($baselineVersion).app" -ErrorAction SilentlyContinue

    if (-not $baselineApp) {
        Write-Host "Unable to find baseline app for $AppName in $baselineFolder"
        return
    }

    if (-not (Test-Path $TargetFolder)) {
        Write-Host "Creating target folder for baselines: $TargetFolder"
        New-Item -ItemType Directory -Path $TargetFolder | Out-Null
    }

    Write-Host "Copying $($baselineApp.FullName) to $TargetFolder"
    Copy-Item -Path $baselineApp.FullName -Destination $TargetFolder | Out-Null

    return $baselineVersion
}

<#
.Synopsis
    Generate an AppSourceCop.json with version and name of the extension
.Parameter AppProjectFolder
    Path to the folder where AppSourceCop.json should be generated to
.Parameter Version
    Baseline version of the extension
.Parameter AppName
    Name of the extension
.Parameter Publisher
    Publisher of the extension
#>
function Update-AppSourceCopVersion
(
    [Parameter(Mandatory = $true)]
    [string] $AppProjectFolder,
    [Parameter(Mandatory = $true)]
    [string] $AppName,
    [Parameter(Mandatory = $true)]
    [string] $BaselineVersion,
    [Parameter(Mandatory = $false)]
    [string] $Publisher = "Microsoft",
    [Parameter(Mandatory = $false)]
    [string] $BuildMode
) {
    Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1

    if ($BaselineVersion -match "^(\d+)\.(\d+)\.(\d+)$") {
        Write-Host "Baseline version is missing revision number. Adding revision number 0 to the baseline version" -ForegroundColor Yellow
        $BaselineVersion = $BaselineVersion + ".0"
    }

    if (-not ($BaselineVersion -and $BaselineVersion -match "^([0-9]+\.){3}[0-9]+$" )) {
        throw "Extension Compatibile Version cannot be null or invalid format. Valid format should be like '1.0.2.0'"
    }

    $appSourceCopJsonPath = Join-Path $AppProjectFolder AppSourceCop.json

    if (!(Test-Path $appSourceCopJsonPath)) {
        Write-Host "Creating AppSourceCop.json with version $BaselineVersion in path $appSourceCopJsonPath" -ForegroundColor Yellow
        New-Item $appSourceCopJsonPath -type file
        $appSourceJson = @{version = '' }
    }
    else {
        $appSourceJson = Get-Content $appSourceCopJsonPath -Raw | ConvertFrom-Json
    }

    Write-Host "Setting 'version:$BaselineVersion' in AppSourceCop.json" -ForegroundColor Yellow
    $appSourceJson["version"] = $BaselineVersion

    Write-Host "Setting 'name:$AppName' value in AppSourceCop.json" -ForegroundColor Yellow
    $appSourceJson["name"] = $AppName

    Write-Host "Setting 'publisher:$Publisher' value in AppSourceCop.json" -ForegroundColor Yellow
    $appSourceJson["publisher"] = $Publisher

    $buildVersion = Get-ConfigValue -Key "repoVersion" -ConfigType AL-Go
    Write-Host "Setting 'obsoleteTagVersion:$buildVersion' value in AppSourceCop.json" -ForegroundColor Yellow
    $appSourceJson["obsoleteTagVersion"] = $buildVersion

    # All major versions greater than current but less or equal to main should be allowed
    $currentBuildVersion = [int] $buildVersion.Split('.')[0]
    $maxAllowedObsoleteVersion = [int] (Get-ConfigValue -ConfigType BuildConfig -Key "MaxAllowedObsoleteVersion")
    $obsoleteTagAllowedVersions = @()

    # Add 3 versions for tasks built with CLEANpreProcessorSymbols
    if ($BuildMode -eq "Clean") {
        $maxAllowedObsoleteVersion += 3
    }

    for ($i = $currentBuildVersion + 1; $i -le $maxAllowedObsoleteVersion; $i++) {
        $obsoleteTagAllowedVersions += "$i.0"
    }

    Write-Host "Setting 'obsoleteTagAllowedVersions:$obsoleteTagAllowedVersions' value in AppSourceCop.json" -ForegroundColor Yellow
    $appSourceJson["obsoleteTagAllowedVersions"] = $obsoleteTagAllowedVersions -join ','

    Write-Host "Updating AppSourceCop.json done successfully" -ForegroundColor Green
    $appSourceJson | ConvertTo-Json | Out-File $appSourceCopJsonPath -Encoding ASCII -Force

    if (-not (Test-Path $appSourceCopJsonPath)) {
        throw "AppSourceCop.json does not exist in path: $appSourceCopJsonPath"
    }

    return $appSourceCopJsonPath
}

Export-ModuleMember -Function *-*
