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

function Get-NugetExe() {
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

function Get-PackageFromNuget() {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageId,
        [Parameter(Mandatory=$true)]
        [string]$Version,
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )

    $NugetExePath = Get-NugetExe -OutputPath $OutputPath

    $NugetPackagePath = Join-Path $OutputPath "$PackageId.$Version"
    if (!(Test-Path $NugetPackagePath)) {
        Write-Host "install $PackageId -Version $Version -OutputDirectory $OutputPath -Source https://api.nuget.org/v3/index.json"
        $NugetExeArguments = "install $PackageId -Version $Version -OutputDirectory $OutputPath -Source https://api.nuget.org/v3/index.json"
        Invoke-Expression "$NugetExePath $NugetExeArguments" | Out-Null
    }

    return $NugetPackagePath
}

Export-ModuleMember -Function *-*
