function Get-GitBranchName() {
    if ($ENV:GITHUB_REF_NAME) {
        return $ENV:GITHUB_REF_NAME
    }
    return git rev-parse --abbrev-ref HEAD
}

function Get-BaseFolder() {
    if ($ENV:GITHUB_WORKSPACE) {
        return $ENV:GITHUB_WORKSPACE
    }
    return git rev-parse --show-toplevel
}

function Get-BuildMode() {
    if ($ENV:BuildMode) {
        return $ENV:BuildMode
    }
    return 'Default'
}

<#
.Synopsis
    Get the value of a key from the BuildConfig.json or AL-GO-Settings file
.Parameter ConfigType
    The type of config file to read from. Can be either "BuildConfig" or "AL-GO"
.Parameter Key
    The key to read the value from
#>
function Get-ConfigValueFromKey() {
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("BuildConfig","AL-GO")]
        [string]$ConfigType = "AL-GO",
        [Parameter(Mandatory=$true)]
        [string]$Key
    )

    if ($ConfigType -eq "BuildConfig") {
        $ConfigPath = Join-Path (Get-BaseFolder) "Build/BuildConfig.json" -Resolve
    } else {
        $ConfigPath = Join-Path (Get-BaseFolder) ".github/AL-Go-Settings.json" -Resolve
    }
    $BuildConfig = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
    return $BuildConfig.$Key
}

<#
.Synopsis
    Get the value of a key from the BuildConfig.json or AL-GO-Settings file
.Parameter ConfigType
    The type of config file to read from. Can be either "BuildConfig" or "AL-GO"
.Parameter Key
    The key to write to
.Parameter Value
    The value to set the key to
#>
function Set-ConfigValueFromKey() {
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("BuildConfig","AL-GO")]
        [string]$ConfigType = "AL-GO",
        [Parameter(Mandatory=$true)]
        [string]$Key,
        [Parameter(Mandatory=$true)]
        [string]$Value
    )

    if ($ConfigType -eq "BuildConfig") {
        $ConfigPath = Join-Path (Get-BaseFolder) "Build/BuildConfig.json" -Resolve
    } else {
        $ConfigPath = Join-Path (Get-BaseFolder) ".github/AL-Go-Settings.json" -Resolve
    }
    $BuildConfig = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
    $BuildConfig.$Key = $Value
    $BuildConfig | ConvertTo-Json -Depth 100 | Set-Content -Path $ConfigPath
}

<#
.Synopsis
    Get the nuget.exe if it doesn't exist
    Downloads the nuget.exe if it doesn't exist
.Parameter OutputPath
    The path where the nuget.exe will be downloaded to
#>
function Restore-NugetExe() {
    param(
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )

    if (!(Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
    }

    $NugetExePath = Join-Path $OutputPath "nuget.exe"
    if (!(Test-Path $NugetExePath)) {
        Write-Host "Downloading nuget.exe"
        Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $NugetExePath | Out-Null
    }
    return $NugetExePath
}

<#
.Synopsis
    Get a package from Nuget.org
.Parameter PackageId
    The package id
.Parameter Version
    The package version
.Parameter OutputPath
    The path where the package will be downloaded
#>
function Get-PackageFromNuget() {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageId,
        [Parameter(Mandatory=$true)]
        [string]$Version,
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )

    $NugetExePath = Restore-NugetExe -OutputPath $OutputPath

    $NugetPackagePath = Join-Path $OutputPath "$PackageId.$Version"
    if (!(Test-Path $NugetPackagePath)) {
        Write-Host "install $PackageId -Version $Version -OutputDirectory $OutputPath -Source https://api.nuget.org/v3/index.json"
        $NugetExeArguments = "install $PackageId -Version $Version -OutputDirectory $OutputPath -Source https://api.nuget.org/v3/index.json"
        Invoke-Expression "$NugetExePath $NugetExeArguments" | Out-Null
    }

    return $NugetPackagePath
}

<#
.Synopsis
    Downloads the AL-Go Helper script
#>
function Get-ALGOHelper() 
{
    $webClient = New-Object System.Net.WebClient
    $webClient.CachePolicy = New-Object System.Net.Cache.RequestCachePolicy -argumentList ([System.Net.Cache.RequestCacheLevel]::NoCacheNoStore)
    $webClient.Encoding = [System.Text.Encoding]::UTF8
    Write-Host "Downloading AL-Go Helper script"
    $ALGoHelperPath = "$([System.IO.Path]::GetTempFileName()).ps1"
    $webClient.DownloadFile('https://raw.githubusercontent.com/microsoft/AL-Go-Actions/preview/AL-Go-Helper.ps1', $ALGoHelperPath)
    return $ALGoHelperPath
}

<#
.Synopsis
    Downloads the AL-Go Helper script
#>
function Get-GithubHelper() 
{
    $webClient = New-Object System.Net.WebClient
    $webClient.CachePolicy = New-Object System.Net.Cache.RequestCachePolicy -argumentList ([System.Net.Cache.RequestCacheLevel]::NoCacheNoStore)
    $webClient.Encoding = [System.Text.Encoding]::UTF8
    Write-Host "Downloading GitHub Helper module"
    $GitHubHelperPath = "$([System.IO.Path]::GetTempFileName()).psm1"
    $webClient.DownloadFile('https://raw.githubusercontent.com/microsoft/AL-Go-Actions/preview/Github-Helper.psm1', $GitHubHelperPath)
    return $GitHubHelperPath
}

Export-ModuleMember -Function *-*
