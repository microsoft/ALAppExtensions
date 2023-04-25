Add-Type -AssemblyName System.Web
$credential = New-Object pscredential admin, (ConvertTo-SecureString -String ([System.Web.Security.Membership]::GeneratePassword(10, 3)) -AsPlainText -Force)

Invoke-Expression "$PSScriptRoot\System Application\.AL-Go\localDevEnv.ps1 -containerName test -auth UserPassword -credential $credential"