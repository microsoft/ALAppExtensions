[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    $Project,
    [Parameter(Mandatory=$true)]
    $BuildMode
)

$baselineVersion = $env:baselineVersion

if(-not $baselineVersion) {
    Write-Host "Baseline version is not defined"
}
else {
    Write-Host "Baseline version: $baselineVersion"

    $baselineURL = Get-BCArtifactUrl -type Sandbox -country 'W1' -select Closest -version $baselineVersion # W1 because Modules are not localized
    if(-not $baselineURL) {
        throw "Unable to find URL for baseline version $baselineVersion"
    }
    
    Write-Host "Baseline URL: $baselineURL"
    $baselineFolder = Join-Path $([System.IO.Path]::GetTempPath()) 'baselines'

    Download-Artifacts -artifactUrl $baselineURL -basePath $baselineFolder
}
