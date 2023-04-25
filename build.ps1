param
(
    [string] $ALGoProject = 'Test Stability Tools'
)

Add-Type -AssemblyName System.Web
$credential = New-Object pscredential admin, (ConvertTo-SecureString -String ([System.Web.Security.Membership]::GeneratePassword(20, 5)) -AsPlainText -Force)

$scriptPath = Join-Path $PSScriptRoot "$ALGoProject\.AL-Go\localDevEnv.ps1" -Resolve
& $scriptPath -containerName test -auth UserPassword -credential $credential -licenseFileUrl 'none'