param(
    [String[]]$Files,
    [string]$AzureKeyVaultURI,
    [string]$AzureKeyVaultClientID,
    [string]$AzureKeyVaultClientSecret,
    [string]$AzureKeyVaultTenantID,
    [string]$AzureKeyVaultCertificateName,
    [string]$Description = "",
    [string]$DescriptionUrl = "",
    [string]$TimestampService = "http://timestamp.digicert.com",
    [string]$TimestampDigest = "sha256",
    [string]$FileDigest = "sha256"
)

#Install-NAVSipCryptoProviderFromNavContainer 

#$ClientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AzureKeyVaultClientSecret))

Write-Host "Signing files: $Files"
Write-Host "AzureKeyVaultCertificateName: $AzureKeyVaultCertificateName"


AzureSignTool.exe sign $Files `
                        --azure-key-vault-url "$AzureKeyVaultURI" `
                        --azure-key-vault-client-id "$AzureKeyVaultClientID" `
                        --azure-key-vault-client-secret "$ClientSecret" `
                        --azure-key-vault-tenant-id "$AzureKeyVaultTenantID" `
                        --azure-key-vault-certificate "$AzureKeyVaultCertificateName" `
                        --description "$Description" `
                        --description-url "$DescriptionUrl" `
                        --timestamp-rfc3161 "$TimestampService" `
                        --timestamp-digest "$TimestampDigest" `
                        --file-digest "$FileDigest"
