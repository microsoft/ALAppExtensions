$BCContainerName =  Read-Host -Prompt 'Enter your docker container name'
$LocalDLLPath = Read-Host -Prompt 'Enter the location of the IDAutomation files'

Write-Host "Installing Latest version of the Module NavContainerHelper"
install-module navcontainerhelper -force -Scope CurrentUser
Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\160\Service\Microsoft.Dynamics.Nav.Management.psd1' -WarningAction SilentlyContinue | Out-Null

Write-Host "Uploading Dotnet libraries to container"
Copy-FileToNavContainer -containerName $BCContainerName -localPath $LocalDLLPath -containerPath "C:\Program Files\Microsoft Dynamics NAV\160\Service\Add-Ins\IDAutomation.NetAssembly.dll"

Write-Host '8. Restart Service'
Restart-NAVServerInstance -ServerInstance $BCServerInstance 

Write-Host "Verify Dotnet libraries at container"
Enter-NavContainer -containerName $BCContainerName


Write-Host "Uploading Fonts to docker container"
#Add-FontsToNavContainer -containerName $BCserverInstance -path "C:\Windows\Fonts\arial.ttf"