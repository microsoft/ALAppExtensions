#
# Script for creating cloud development environment
# Please do not modify this script as it will be auto-updated from the AL-Go Template
# Recommended approach is to use as is or add a script (freddyk-devenv.ps1), which calls this script with the user specific parameters
#
Param(
    [string] $environmentName = "",
    [bool] $reuseExistingEnvironment,
    [switch] $fromVSCode,
    [switch] $clean
)

$errorActionPreference = "Stop"; $ProgressPreference = "SilentlyContinue"; Set-StrictMode -Version 2.0

function DownloadHelperFile {
    param(
        [string] $url,
        [string] $folder
    )

    $prevProgressPreference = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
    $name = [System.IO.Path]::GetFileName($url)
    Write-Host "Downloading $name from $url"
    $path = Join-Path $folder $name
    Invoke-WebRequest -UseBasicParsing -uri $url -OutFile $path
    $ProgressPreference = $prevProgressPreference
    return $path
}

try {
Clear-Host
Write-Host
Write-Host -ForegroundColor Yellow @'
   _____ _                 _   _____             ______
  / ____| |               | | |  __ \           |  ____|
 | |    | | ___  _   _  __| | | |  | | _____   __ |__   _ ____   __
 | |    | |/ _ \| | | |/ _` | | |  | |/ _ \ \ / /  __| | '_ \ \ / /
 | |____| | (_) | |_| | (_| | | |__| |  __/\ V /| |____| | | \ V /
  \_____|_|\___/ \__,_|\__,_| |_____/ \___| \_/ |______|_| |_|\_/

'@

$tmpFolder = Join-Path ([System.IO.Path]::GetTempPath()) "$([Guid]::NewGuid().ToString())"
New-Item -Path $tmpFolder -ItemType Directory -Force | Out-Null
$GitHubHelperPath = DownloadHelperFile -url 'https://raw.githubusercontent.com/microsoft/AL-Go-Actions/v6.3/Github-Helper.psm1' -folder $tmpFolder
$ALGoHelperPath = DownloadHelperFile -url 'https://raw.githubusercontent.com/microsoft/AL-Go-Actions/v6.3/AL-Go-Helper.ps1' -folder $tmpFolder
DownloadHelperFile -url 'https://raw.githubusercontent.com/microsoft/AL-Go-Actions/v6.3/Packages.json' -folder $tmpFolder | Out-Null

Import-Module $GitHubHelperPath
. $ALGoHelperPath -local

$baseFolder = GetBaseFolder -folder $PSScriptRoot
$project = GetProject -baseFolder $baseFolder -projectALGoFolder $PSScriptRoot

Write-Host @'

This script will create a cloud based development environment (Business Central SaaS Sandbox) for your project.
All apps and test apps will be compiled and published to the environment in the development scope.
The script will also modify launch.json to have a "Cloud Sandbox (<name>)" configuration point to your environment.

'@

if (Test-Path (Join-Path $PSScriptRoot "NewBcContainer.ps1")) {
    Write-Host -ForegroundColor Red "WARNING: The project has a NewBcContainer override defined. Typically, this means that you cannot run a cloud development environment"
}

Write-Host

if (-not $environmentName) {
    $environmentName = Enter-Value `
        -title "Environment name" `
        -question "Please enter the name of the environment to create" `
        -default "$($env:USERNAME)-sandbox" `
        -trimCharacters @('"',"'",' ')
}

if ($PSBoundParameters.Keys -notcontains 'reuseExistingEnvironment') {
    $reuseExistingEnvironment = (Select-Value `
        -title "What if the environment already exists?" `
        -options @{ "Yes" = "Reuse existing environment"; "No" = "Recreate environment" } `
        -question "Select behavior" `
        -default "No") -eq "Yes"
}

CreateDevEnv `
    -kind cloud `
    -caller local `
    -environmentName $environmentName `
    -reuseExistingEnvironment:$reuseExistingEnvironment `
    -baseFolder $baseFolder `
    -project $project `
    -clean:$clean
}
catch {
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)`nStacktrace: $($_.scriptStackTrace)"
}
finally {
    if ($fromVSCode) {
        Read-Host "Press ENTER to close this window"
    }
}
