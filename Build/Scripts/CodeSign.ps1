param(
    [String]$Files,
    [string]$AzureKeyVaultURI,
    [string]$AzureKeyVaultClientID,
    [string]$AzureKeyVaultClientSecret,
    [string]$AzureKeyVaultTenantID,
    [string]$AzureKeyVaultCertificateName,
    [string]$TimestampService = "http://timestamp.digicert.com",
    [string]$TimestampDigest = "sha256",
    [string]$FileDigest = "sha256"
)

# TODO: Remove when moving to AL-GO
$webClient = New-Object System.Net.WebClient
$webClient.CachePolicy = New-Object System.Net.Cache.RequestCachePolicy -argumentList ([System.Net.Cache.RequestCacheLevel]::NoCacheNoStore)
$webClient.Encoding = [System.Text.Encoding]::UTF8
Write-Host "Downloading GitHub Helper module"
$GitHubHelperPath = "$([System.IO.Path]::GetTempFileName()).psm1"
$webClient.DownloadFile('https://raw.githubusercontent.com/microsoft/AL-Go-Actions/preview/Github-Helper.psm1', $GitHubHelperPath)
Write-Host "Downloading AL-Go Helper script"
$ALGoHelperPath = "$([System.IO.Path]::GetTempFileName()).ps1"
$webClient.DownloadFile('https://raw.githubusercontent.com/microsoft/AL-Go-Actions/preview/AL-Go-Helper.ps1', $ALGoHelperPath)

Import-Module $GitHubHelperPath
. $ALGoHelperPath -local
# TODO: END

function Get-NavSipFromArtifacts() {
    $artifactTempFolder = Join-Path $([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    $navSipTempFolder = Join-Path $([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())

    try {
        Download-Artifacts -artifactUrl (Get-BCArtifactUrl -type Sandbox) -includePlatform -basePath $artifactTempFolder | Out-Null
        Write-Host "Downloaded artifacts to $artifactTempFolder"
        $navsip = Get-ChildItem -Path $artifactTempFolder -Filter "navsip.dll" -Recurse
        Write-Host "Found navsip at $($navsip.FullName)"
        New-Item -Path $navSipTempFolder -ItemType Directory -Force -Verbose
        Copy-Item -Path $navsip.FullName -Destination "$navSipTempFolder/navsip.dll" -Force -Verbose
        Write-Host "Copied navsip to $navSipTempFolder"
    } finally {
        Remove-Item -Path $artifactTempFolder -Recurse -Force
    }
    
    return Join-Path $navSipTempFolder "navsip.dll" -Resolve
}

function Register-NavSip() {
    $navsipPath = Get-NavSipFromArtifacts
    $navSip64Path = "C:\Windows\System32\NavSip.dll"
    $navSip32Path = "C:\Windows\SysWow64\NavSip.dll"

    try {
        Write-Host "Copy $navsipPath to $navSip64Path"
        Copy-Item -Path $navsipPath -Destination $navSip64Path -Force
        Write-Host "Registering $navSip64Path"
        RegSvr32 /s $navSip64Path
    }
    catch {
        Write-Host "Failed to copy $navsipPath to $navSip64Path"
    }
    
    try {
        Write-Host "Copy $navsipPath to $navSip32Path"
        Copy-Item -Path $navsipPath -Destination $navSip32Path -Force
        Write-Host "Registering $navSip32Path"
        RegSvr32 /s $navSip32Path
    }
    catch {
        Write-Host "Failed to copy $navsipPath to $navSip32Path"
    }

}

$BcContainerHelperPath = DownloadAndImportBcContainerHelper -baseFolder $ENV:GITHUB_WORKSPACE 
Register-NavSip

Write-Host "Signing files:"
$Files | ForEach-Object { 
    Write-Host "- $_" 
}

AzureSignTool sign --file-digest $FileDigest `
    --azure-key-vault-url $AzureKeyVaultURI `
    --azure-key-vault-client-id $AzureKeyVaultClientID `
    --azure-key-vault-tenant-id $AzureKeyVaultTenantID `
    --azure-key-vault-client-secret $AzureKeyVaultClientSecret `
    --azure-key-vault-certificate $AzureKeyVaultCertificateName `
    --timestamp-rfc3161 "$TimestampService" `
    --timestamp-digest $TimestampDigest `
    --verbose `
    $Files

CleanupAfterBcContainerHelper -bcContainerHelperPath $bcContainerHelperPath
