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

#Install-NAVSipCryptoProviderFromNavContainer 

#$ClientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AzureKeyVaultClientSecret))

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