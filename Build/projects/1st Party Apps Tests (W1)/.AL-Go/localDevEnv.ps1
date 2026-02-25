<#
.SYNOPSIS
    Creates a local development environment for Business Central AL development using Docker containers.

.DESCRIPTION
    This script sets up a local development environment by:
    - Creating a Business Central container using Docker
    - Compiling and publishing all apps and test apps to the development scope
    - Configuring launch.json for Visual Studio Code with Local Sandbox configuration
    - Optionally applying custom settings to override repository settings

    The script requires Docker to be installed and configured to run Windows containers.
    If Docker setup fails, users can alternatively run cloudDevEnv.ps1 for cloud-based development.

    RECOMMENDED USAGE:
    Instead of modifying this script directly (which will be overwritten during AL-Go updates),
    create a custom script that calls this one with your preferred parameters. For example,
    create a file named after yourself (e.g., 'john-devenv.ps1') that contains:

    # My personal development environment script
    $mySettings = '{"country":"us","artifact":"////nextminor"}'
    . .\.AL-Go\localDevEnv.ps1 -containerName "mydevenv" -auth UserPassword -customSettings $mySettings

    This approach allows you to:
    - Maintain your personal preferences without losing them during updates
    - Share your setup with team members
    - Version control your custom development configurations
    - Easily switch between different development scenarios

.PARAMETER containerName
    The name of the Docker container to create. If not specified, the script will prompt for input.
    Default prompts for "bcserver" if not provided.

.PARAMETER auth
    Authentication mechanism for the container. Valid values are "UserPassword" or "Windows".
    If not specified, the script will prompt the user to select the authentication method.

.PARAMETER credential
    PSCredential object containing username and password for container authentication.
    If not provided, the script will prompt for credentials based on the selected auth method.

.PARAMETER licenseFileUrl
    Local path or secure download URL to a Business Central license file.
    For AppSource apps targeting BC versions prior to 22, a developer license with object ID permissions is required.
    For PTEs, this is optional but can be useful for dependent app object IDs.
    Set to "none" to skip license file input.

.PARAMETER fromVSCode
    Switch parameter indicating the script is being run from Visual Studio Code.
    When specified, the script will pause at the end waiting for user input before closing.

.PARAMETER accept_insiderEula
    Switch parameter to automatically accept the insider EULA when using Business Central insider builds.
    Required when working with insider artifacts.

.PARAMETER clean
    Switch parameter to create a clean development environment without compiling and publishing apps.
    Useful for setting up a fresh container without deploying any applications.

.PARAMETER customSettings
    JSON string containing custom settings that override repository settings.
    These settings have the highest precedence and can be used to override artifact URLs,
    country settings, or other configuration without modifying repository files.

.EXAMPLE
    .\localDevEnv.ps1
    Runs the script interactively, prompting for all required parameters.

.EXAMPLE
    .\localDevEnv.ps1 -containerName "mydevenv" -auth "UserPassword"
    Creates a container named "mydevenv" with username/password authentication, prompting for credentials and LicenseFile.

.EXAMPLE
    .\localDevEnv.ps1 -clean
    Creates a clean development environment without compiling and publishing apps.

.EXAMPLE
    .\localDevEnv.ps1 -customSettings '{"country":"dk","artifact":"////nextminor"}'
    Creates a development environment with custom settings for Denmark country and specific artifact.

.EXAMPLE
    # Programmatic setup with credentials and custom settings
    $Username = "SUPER"
    $Password = "<some password>"
    $cred = New-Object System.Management.Automation.PSCredential ($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))
    $containerName = "bcserver"
    $settings = '{"artifact": "////nextminor"}'

    . ./localDevEnv.ps1 -containerName $containerName -auth UserPassword -credential $cred -accept_insiderEula -licenseFileUrl "none" -customSettings $settings

    Creates a development environment with predefined credentials, using next minor version artifact, accepting insider EULA, and no license file.

.NOTES
    - Requires Docker Desktop to be installed and running with Windows container support
    - For AppSource apps, may require a developer license for BC versions prior to 22
    - Script automatically downloads required AL-Go helper modules and actions
    - Modifies launch.json in VS Code workspace for Local Sandbox configuration
    - Custom settings parameter allows runtime override of repository settings

.LINK
    https://aka.ms/algosettings - AL-Go Settings Documentation
#>

Param(
    [string] $containerName = "",
    [ValidateSet("UserPassword", "Windows")]
    [string] $auth = "",
    [pscredential] $credential = $null,
    [string] $licenseFileUrl = "",
    [switch] $fromVSCode,
    [switch] $accept_insiderEula,
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
  _                     _   _____             ______
 | |                   | | |  __ \           |  ____|
 | |     ___   ___ __ _| | | |  | | _____   __ |__   _ ____   __
 | |    / _ \ / __/ _` | | | |  | |/ _ \ \ / /  __| | '_ \ \ / /
 | |____ (_) | (__ (_| | | | |__| |  __/\ V /| |____| | | \ V /
 |______\___/ \___\__,_|_| |_____/ \___| \_/ |______|_| |_|\_/

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

This script will create a docker based local development environment for your project.

NOTE: You need to have Docker installed, configured and be able to create Business Central containers for this to work.
If this fails, you can setup a cloud based development environment by running cloudDevEnv.ps1

All apps and test apps will be compiled and published to the environment in the development scope.
The script will also modify launch.json to have a Local Sandbox configuration point to your environment.

'@

$settings = ReadSettings -baseFolder $baseFolder -project $project -userName $env:USERNAME -workflowName 'localDevEnv'

Write-Host "Checking System Requirements"
$dockerProcess = (Get-Process "dockerd" -ErrorAction Ignore)
if (!($dockerProcess)) {
    Write-Host -ForegroundColor Red "Dockerd process not found. Docker might not be started, not installed or not running Windows Containers."
}
if ($settings.keyVaultName) {
    if (-not (Get-Module -ListAvailable -Name 'Az.KeyVault')) {
        Write-Host -ForegroundColor Red "A keyvault name is defined in Settings, you need to have the Az.KeyVault PowerShell module installed (use Install-Module az) or you can set the keyVaultName to an empty string in the user settings file ($($ENV:UserName).settings.json)."
    }
}

Write-Host

if (-not $containerName) {
    $containerName = Enter-Value `
        -title "Container name" `
        -question "Please enter the name of the container to create" `
        -default "bcserver" `
        -trimCharacters @('"',"'",' ')
}

if (-not $auth) {
    $auth = Select-Value `
        -title "Authentication mechanism for container" `
        -options @{ "Windows" = "Windows Authentication"; "UserPassword" = "Username/Password authentication" } `
        -question "Select authentication mechanism for container" `
        -default "UserPassword"
}

if (-not $credential) {
    if ($auth -eq "Windows") {
        $credential = Get-Credential -Message "Please enter your Windows Credentials" -UserName $env:USERNAME
        $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
        $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$credential.UserName,$credential.GetNetworkCredential().password)
        if ($null -eq $domain.name) {
            Write-Host -ForegroundColor Red "Unable to verify your Windows Credentials, you might not be able to authenticate to your container"
        }
    }
    else {
        $credential = Get-Credential -Message "Please enter username and password for your container" -UserName "admin"
    }
}

if (-not $licenseFileUrl) {
    if ($settings.type -eq "AppSource App") {
        $description = "When developing AppSource Apps for Business Central versions prior to 22, your local development environment needs the developer licensefile with permissions to your AppSource app object IDs"
        $default = "none"
    }
    else {
        $description = "When developing PTEs, you can optionally specify a developer licensefile with permissions to object IDs of your dependant apps"
        $default = "none"
    }

    $licenseFileUrl = Enter-Value `
        -title "LicenseFileUrl" `
        -description $description `
        -question "Local path or a secure download URL to license file " `
        -default $default `
        -doNotConvertToLower `
        -trimCharacters @('"',"'",' ')
}

if ($licenseFileUrl -eq "none") {
    $licenseFileUrl = ""
}

CreateDevEnv `
    -kind local `
    -caller local `
    -containerName $containerName `
    -baseFolder $baseFolder `
    -project $project `
    -auth $auth `
    -credential $credential `
    -licenseFileUrl $licenseFileUrl `
    -accept_insiderEula:$accept_insiderEula `
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
