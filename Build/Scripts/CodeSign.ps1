param(
    [String]$Files,
    [string]$AzureKeyVaultURI,
    [string]$AzureKeyVaultClientID,
    [string]$AzureKeyVaultClientSecret,
    [string]$AzureKeyVaultTenantID,
    [string]$AzureKeyVaultCertificateName,
    [string]$TimestampService = "http://timestamp.digicert.com",
    [string]$TimestampDigest = "sha256",
    [string]$FileDigest = "sha256",
    [string]$Project
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

$BcContainerHelperPath = DownloadAndImportBcContainerHelper -baseFolder $ENV:GITHUB_WORKSPACE 

$ContainerName = GetContainerName -project $Project
Write-Host "Container name: $ContainerName - Project: $Project"
Write-Host "env:containerName $env:containerName"

Install-NAVSipCryptoProviderFromNavContainer -containerName $env:containerName

Write-Host "Signing files: $Files"

AzureSignTool sign --file-digest $FileDigest `
    --azure-key-vault-url $AzureKeyVaultURI `
    --azure-key-vault-client-id $AzureKeyVaultClientID `
    --azure-key-vault-tenant-id $AzureKeyVaultTenantID `
    --azure-key-vault-client-secret $AzureKeyVaultClientSecret `
    --azure-key-vault-certificate $AzureKeyVaultCertificateName `
    --timestamp-rfc3161 $TimestampService `
    --timestamp-digest $TimestampDigest `
    --verbose `
    $Files

CleanupAfterBcContainerHelper -bcContainerHelperPath $bcContainerHelperPath
