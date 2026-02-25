<#
.SYNOPSIS
    Creates a cloud-based development environment for Business Central AL development using SaaS Sandbox.

.DESCRIPTION
    This script sets up a cloud-based development environment by:
    - Creating a Business Central SaaS Sandbox environment
    - Compiling and publishing all apps and test apps to the development scope
    - Configuring launch.json for Visual Studio Code with Cloud Sandbox configuration
    - Optionally applying custom settings to override repository settings

    The script will prompt you interactively for authentication using device code flow.
    For automated/unattended execution, you can configure AdminCenterApiCredentials as a GitHub secret
    or in Azure KeyVault. See https://aka.ms/algosettings for more information about AdminCenterApiCredentials.

    This is an alternative to localDevEnv.ps1 for users who cannot run Docker containers locally.

    RECOMMENDED USAGE:
    Instead of modifying this script directly (which will be overwritten during AL-Go updates),
    create a custom script that calls this one with your preferred parameters. For example,
    create a file named after yourself (e.g., 'john-devenv.ps1') that contains:

    # My personal cloud development environment script
    $mySettings = '{"country":"us"}'
    . .\.AL-Go\cloudDevEnv.ps1 -environmentName "john-sandbox" -reuseExistingEnvironment $true -customSettings $mySettings

    This approach allows you to:
    - Maintain your personal preferences without losing them during updates
    - Share your setup with team members
    - Version control your custom development configurations
    - Easily switch between different development scenarios

.PARAMETER environmentName
    The name of the cloud sandbox environment to create or reuse.
    If not specified, the script will prompt for input with a default of "{username}-sandbox".

.PARAMETER reuseExistingEnvironment
    Boolean parameter indicating whether to reuse an existing environment with the same name.
    If $true, the script will use the existing environment if it exists.
    If $false, the script will recreate the environment (deleting the old one if it exists).
    If not specified, the script will prompt the user to select the behavior.

.PARAMETER fromVSCode
    Switch parameter indicating the script is being run from Visual Studio Code.
    When specified, the script will pause at the end waiting for user input before closing.

.PARAMETER clean
    Switch parameter to create a clean development environment without compiling and publishing apps.
    Useful for setting up a fresh environment without deploying any applications.

.PARAMETER customSettings
    JSON string containing custom settings that override repository settings.
    These settings have the highest precedence and can be used to override country,
    or other configuration without modifying repository files.

.EXAMPLE
    .\cloudDevEnv.ps1
    Runs the script interactively, prompting for all required parameters.

.EXAMPLE
    .\cloudDevEnv.ps1 -environmentName "my-sandbox" -reuseExistingEnvironment $true
    Creates or reuses a cloud sandbox named "my-sandbox".

.EXAMPLE
    .\cloudDevEnv.ps1 -clean
    Creates a clean cloud development environment without compiling and publishing apps.

.EXAMPLE
    .\cloudDevEnv.ps1 -customSettings '{"country":"dk"}'
    Creates a cloud development environment with custom settings for Denmark country.

.EXAMPLE
    # Programmatic setup with custom settings
    $envName = "test-sandbox"
    $settings = '{"country": "us"}'

    . ./cloudDevEnv.ps1 -environmentName $envName -reuseExistingEnvironment $true -customSettings $settings

    Creates or reuses a cloud development environment with custom country setting.

.NOTES
    - Authentication is handled interactively via device code flow (https://aka.ms/devicelogin)
    - For unattended execution, configure AdminCenterApiCredentials secret (see link below)
    - Does not require Docker to be installed
    - Script automatically downloads required AL-Go helper modules and actions
    - Modifies launch.json in VS Code workspace for Cloud Sandbox configuration
    - Custom settings parameter allows runtime override of repository settings
    - If NewBcContainer.ps1 override exists, cloud development may not be supported

.LINK
    https://aka.ms/algosettings - AL-Go Settings Documentation
    https://github.com/microsoft/AL-Go/blob/main/Scenarios/CreateOnlineDevEnv2.md - Online Dev Environment Setup
#>

Param(
    [string] $environmentName = "",
    [bool] $reuseExistingEnvironment,
    [switch] $fromVSCode,
    [switch] $clean,
    [string] $customSettings = ""
)

$errorActionPreference = "Stop"; $ProgressPreference = "SilentlyContinue"; Set-StrictMode -Version 2.0

function DownloadHelperFile {
    param(
        [string] $url,
        [string] $folder,
        [switch] $notifyAuthenticatedAttempt
    )

    $prevProgressPreference = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
    $name = [System.IO.Path]::GetFileName($url)
    Write-Host "Downloading $name from $url"
    $path = Join-Path $folder $name
    try {
        Invoke-WebRequest -UseBasicParsing -uri $url -OutFile $path
    }
    catch {
        if ($notifyAuthenticatedAttempt) {
            Write-Host -ForegroundColor Red "Failed to download $name, trying authenticated download"
        }
        Invoke-WebRequest -UseBasicParsing -uri $url -OutFile $path -Headers @{ "Authorization" = "token $(gh auth token)" }
    }
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
$GitHubHelperPath = DownloadHelperFile -url 'https://raw.githubusercontent.com/microsoft/AL-Go/0c7b1de38ba518aaf5fdee3902c2d2ae886ede32/Actions/Github-Helper.psm1' -folder $tmpFolder -notifyAuthenticatedAttempt
$ReadSettingsModule = DownloadHelperFile -url 'https://raw.githubusercontent.com/microsoft/AL-Go/0c7b1de38ba518aaf5fdee3902c2d2ae886ede32/Actions/.Modules/ReadSettings.psm1' -folder $tmpFolder
$debugLoggingModule = DownloadHelperFile -url 'https://raw.githubusercontent.com/microsoft/AL-Go/0c7b1de38ba518aaf5fdee3902c2d2ae886ede32/Actions/.Modules/DebugLogHelper.psm1' -folder $tmpFolder
$ALGoHelperPath = DownloadHelperFile -url 'https://raw.githubusercontent.com/microsoft/AL-Go/0c7b1de38ba518aaf5fdee3902c2d2ae886ede32/Actions/AL-Go-Helper.ps1' -folder $tmpFolder
DownloadHelperFile -url 'https://raw.githubusercontent.com/microsoft/AL-Go/0c7b1de38ba518aaf5fdee3902c2d2ae886ede32/Actions/.Modules/settings.schema.json' -folder $tmpFolder | Out-Null
DownloadHelperFile -url 'https://raw.githubusercontent.com/microsoft/AL-Go/0c7b1de38ba518aaf5fdee3902c2d2ae886ede32/Actions/Environment.Packages.proj' -folder $tmpFolder | Out-Null

Import-Module $GitHubHelperPath
Import-Module $ReadSettingsModule
Import-Module $debugLoggingModule
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
    -clean:$clean `
    -customSettings $customSettings
}
catch {
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)`nStacktrace: $($_.scriptStackTrace)"
}
finally {
    if ($fromVSCode) {
        Read-Host "Press ENTER to close this window"
    }
}
