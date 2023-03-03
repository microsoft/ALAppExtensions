function Update-AppSourceCopVersionInContainer
(
    [Parameter(Mandatory=$true)] [string] $ContainerName, 
    [Parameter(Mandatory=$true)] [string] $AppProjectFolder, 
    [Parameter(Mandatory=$true)] [string] $Version,
    [Parameter(Mandatory=$false)] [string] $ExtensionName = $null,
    [Parameter(Mandatory=$false)] [string] $Publisher = $null
) {
    Update-AppSourceCopVersion -ExtensionFolder $AppProjectFolder -Version $Version -ExtensionName $ExtensionName -Publisher $Publisher

    $appSourceCopJsonPath = Join-Path $AppProjectFolder "AppSourceCop.json"
    $containerPath = Join-Path (Get-BcContainerPath -containerName $ContainerName -path $AppProjectFolder) "AppSourceCop.json"

    if (-not (Test-Path $appSourceCopJsonPath)) {
        throw "AppSourceCop.json does not exist in path: $appSourceCopJsonPath"
    }

    Write-Host "Copy-FileToBcContainer -containerName $ContainerName -localPath $appSourceCopJsonPath -containerPath $containerPath"
    Copy-FileToBcContainer -containerName $ContainerName -localPath $appSourceCopJsonPath -containerPath $containerPath

    #Remove-Item -Path $appSourceCopJsonPath -Force

    if (Test-Path $appSourceCopJsonPath) {
        Write-Host "$appSourceCopJsonPath exists"
    } else {
        Write-Host "$appSourceCopJsonPath does not exist"
    }
}


function Update-AppSourceCopVersion
(
    [Parameter(Mandatory=$true)] [string] $ExtensionFolder, 
    [Parameter(Mandatory=$true)] [string] $Version,
    [Parameter(Mandatory=$false)] [string] $ExtensionName = $null,
    [Parameter(Mandatory=$false)] [string] $Publisher = $null
)
{
    $appSourceCopJsonPath = Join-Path $ExtensionFolder AppSourceCop.json

    if(!(Test-Path $appSourceCopJsonPath))
    {
       Write-Host "Creating AppSourceCop.json with version $Version in path $appSourceCopJsonPath" -ForegroundColor Yellow
       New-Item $appSourceCopJsonPath -type file
       $appSourceJson = @{version=''}
    }
    else
    {
       $json = Get-Content $appSourceCopJsonPath -Raw | ConvertFrom-Json
       $appSourceJson = @{}
       $json.psobject.properties | Foreach-Object { $appSourceJson[$_.Name] = $_.Value }
    }

    if(-not ($Version -and $Version -match "([0-9]+.){3}[0-9]+" ))
    {
        throw "Extension Compatibile Version cannot be null or invalid format. Valid format should be like '1.0.2.0'"
    }

    Write-Host "Setting 'version:$Version' in AppSourceCop.json" -ForegroundColor Yellow
    $appSourceJson.version = $Version

    if($ExtensionName)
    {
        Write-Host "Setting 'name:$ExtensionName' value in AppSourceCop.json" -ForegroundColor Yellow
        $appSourceJson["name"] = $ExtensionName
    }
    
    if($Publisher)
    {
        Write-Host "Setting 'publisher:$Publisher' value in AppSourceCop.json" -ForegroundColor Yellow
        $appSourceJson["publisher"] = $Publisher
    }

    $appSourceJson["obsoleteTagVersion"] = 21.0 #Get-NavBuildVersion

    # All major versions greater than current but less or equal to master should be allowed
    $Current = 21# [int](Get-NavBuildVersion).Split('.')[0]
    $Master = 22 #[int](Get-CurrentBuildVersionFromMaster)
    $obsoleteTagAllowedVersions = @()

    for ($i = $Current + 1; $i -le $Master; $i++)
    {
        $obsoleteTagAllowedVersions += "$i.0"
    }

    $appSourceJson["obsoleteTagAllowedVersions"] = $obsoleteTagAllowedVersions -join ','

    Write-Host "Updating AppSourceCop.json done successfully" -ForegroundColor Green
    $appSourceJson | ConvertTo-Json | Out-File $appSourceCopJsonPath -Encoding ASCII -Force

    return $appSourceCopJsonPath
}

function Get-BaselinesFromContainer {
    Param(
    [string] $BaselineVersion,
    [string] $ApplicationName,
    [string] $ContainerName,
    [string] $AppSymbolsFolder
    )
    if(-not $BaselineVersion) {
        Write-Host "Baseline version is not defined"
    }
    else {
        Write-Host "Baseline version: $BaselineVersion"

        $baselineURL = Get-BCArtifactUrl -type Sandbox -country 'W1' -version $BaselineVersion # W1 because Modules are not localized
        if(-not $baselineURL) {
            throw "Unable to find URL for baseline version $BaselineVersion"
        }
        $baselineFolder = Join-Path $([System.IO.Path]::GetTempPath()) 'baselines'
        
        Write-Host "Baseline URL: $baselineURL"
        Write-Host "Downloading to: $baselineFolder"
        
        Download-Artifacts -artifactUrl $baselineURL -basePath $baselineFolder
        $baselineApp = Get-ChildItem -Path "$baselineFolder/sandbox/$BaselineVersion/w1/Extensions/*$ApplicationName*" -Filter "*.app"

        Write-Host "Container Name: $($ContainerName)"
        Write-Host "appSymbolsFolder: $($AppSymbolsFolder)"

        $containerSymbolsFolder = Get-BcContainerPath -containerName $ContainerName -path $AppSymbolsFolder
        $baselineAppName = $baselineApp.Name
        $containerPath = Join-Path $containerSymbolsFolder $baselineAppName

        Write-Host "Copying $($baselineApp.FullName) to $containerPath"

        Copy-FileToBcContainer -containerName $ContainerName -localPath $baselineApp.FullName -containerPath $containerPath

        Remove-Item -Path $baselineFolder -Recurse -Force
    }
}

Export-ModuleMember -Function *-*