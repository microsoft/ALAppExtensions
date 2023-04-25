Add-Type -AssemblyName System.Web
$credential = New-Object pscredential admin, (ConvertTo-SecureString -String ([System.Web.Security.Membership]::GeneratePassword(10, 3)) -AsPlainText -Force)

$scriptPath = Join-Path $PSScriptRoot "System Application\.AL-Go\localDevEnv.ps1" -Resolve
& $scriptPath -containerName test -auth UserPassword -credential $credential -licenseFileUrl "none"