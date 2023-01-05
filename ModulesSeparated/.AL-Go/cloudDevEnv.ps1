#
# Script for creating cloud development environment
# Please do not modify this script as it will be auto-updated from the AL-Go Template
# Recommended approach is to use as is or add a script (freddyk-devenv.ps1), which calls this script with the user specific parameters
#
Param(
    [string] $environmentName = "",
    [bool] $reuseExistingEnvironment,
    [switch] $fromVSCode
)

$ErrorActionPreference = "stop"
Set-StrictMode -Version 2.0

$pshost = Get-Host
if ($pshost.Name -eq "Visual Studio Code Host") {
    $executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
    Write-Host "Execution Policy is $executionPolicy"
    if ($executionPolicy -eq "Restricted") {
        Write-Host "Changing Execution Policy to RemoteSigned"
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    }
    if ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '') {
        $scriptName = Join-Path $PSScriptRoot $MyInvocation.MyCommand
    }
    else {
        $scriptName = $MyInvocation.InvocationName
    }
    if (Test-Path -Path $scriptName -PathType Leaf) {
        $scriptName = (Get-Item -path $scriptName).FullName
        $pslink = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk"
        if (!(Test-Path $pslink)) {
            $pslink = "powershell.exe"
        }
        Start-Process -Verb runas $pslink @("-Command ""$scriptName"" -fromVSCode -environmentName '$environmentName' -reuseExistingEnvironment `$$reuseExistingEnvironment")
        return
    }
}

try {
$ALGoHelperPath = "$([System.IO.Path]::GetTempFileName()).ps1"
$webClient = New-Object System.Net.WebClient
$webClient.CachePolicy = New-Object System.Net.Cache.RequestCachePolicy -argumentList ([System.Net.Cache.RequestCacheLevel]::NoCacheNoStore)
$webClient.Encoding = [System.Text.Encoding]::UTF8
Write-Host "Downloading AL-Go Helper script"
$webClient.DownloadFile('https://raw.githubusercontent.com/microsoft/AL-Go-Actions/preview/AL-Go-Helper.ps1', $ALGoHelperPath)
. $ALGoHelperPath -local

$baseFolder = Join-Path $PSScriptRoot ".." -Resolve

Clear-Host
Write-Host -ForegroundColor Yellow @'
   _____ _                 _   _____             ______            
  / ____| |               | | |  __ \           |  ____|           
 | |    | | ___  _   _  __| | | |  | | _____   __ |__   _ ____   __
 | |    | |/ _ \| | | |/ _` | | |  | |/ _ \ \ / /  __| | '_ \ \ / /
 | |____| | (_) | |_| | (_| | | |__| |  __/\ V /| |____| | | \ V / 
  \_____|_|\___/ \__,_|\__,_| |_____/ \___| \_/ |______|_| |_|\_/  
                                                                   
'@

Write-Host @'
This script will create a cloud based development environment (Business Central SaaS Sandbox) for your project.
All apps and test apps will be compiled and published to the environment in the development scope.
The script will also modify launch.json to have a "Cloud Sandbox (<name>)" configuration point to your environment.

'@

if (Test-Path (Join-Path $PSScriptRoot "NewBcContainer.ps1")) {
    Write-Host -ForegroundColor Red "WARNING: The project has a NewBcContainer override defined. Typically, this means that you cannot run a cloud development environment"
}

$settings = ReadSettings -baseFolder $baseFolder -userName $env:USERNAME

Write-Host

if (-not $environmentName) {
    $environmentName = Enter-Value `
        -title "Environment name" `
        -question "Please enter the name of the environment to create" `
        -default "$($env:USERNAME)-sandbox"
}

if (-not $PSBoundParameters.ContainsKey('reuseExistingEnvironment')) {
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
    -baseFolder $baseFolder
}
catch {
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)`nStacktrace: $($_.scriptStackTrace)"
}
finally {
    if ($fromVSCode) {
        Read-Host "Press ENTER to close this window"
    }
}
