<#
    .Synopsis
        Build script for AL-Go projects
    .Description
        This script will run localDevEnv.ps1 in the specified AL-Go project
    .Parameter ALGoProject
        The name of the AL-Go project
    .Parameter InsiderSasToken
        The SAS token to use for downloading insider builds
    .Parameter AutoFill
        If specified, the script will generate a random password and use that for the credential
    .Example
        .\build.ps1 -ALGoProject "System Application"
        .\build.ps1 -ALGoProject "Test Stability Tools" -AutoFill
#>
param
(
    [Parameter(Mandatory=$true)]
    [string] $ALGoProject,
    [string] $InsiderSasToken = "",
    [switch] $AutoFill
)

if ($AutoFill) {
    Add-Type -AssemblyName System.Web

    $credential = New-Object pscredential admin, (ConvertTo-SecureString -String ([System.Web.Security.Membership]::GeneratePassword(20, 5)) -AsPlainText -Force)
    $licenseFileUrl = 'none'
    $containerName = "bcserver"
    $auth = "UserPassword"
}

$scriptPath = Join-Path $PSScriptRoot "$ALGoProject\.AL-Go\localDevEnv.ps1" -Resolve
& $scriptPath -containerName $containerName -auth $auth -credential $credential -licenseFileUrl $licenseFileUrl -insiderSasToken $InsiderSasToken