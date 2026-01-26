Param(
    [Parameter(ParameterSetName="ALGo")]
    [Hashtable]$parameters,
    [Parameter(ParameterSetName="Manual")]
    [string]$containerName
)

Import-Module "$PSScriptRoot\EnlistmentHelperFunctions.psm1"

function Get-NavDefaultCompanyName
{
    return "CRONUS International Ltd."
}

if ($PSCmdlet.ParameterSetName -eq 'ALGo') {
    $containerName = $parameters.ContainerName
}

# Unpublish apps that should not be published
$installedApps = Get-BcContainerAppInfo -containerName $parameters.ContainerName -tenantSpecificProperties -sort DependenciesLast
$appsToBeUnPublished = (Get-ConfigValue -ConfigType "BuildConfig" -Key "AppsNotToBePublished")
$installedApps | ForEach-Object {
    if ($_.Name -in $appsToBeUnPublished) {
        Write-Host "Unpublishing $($_.Name)"
        Unpublish-BcContainerApp -containerName $parameters.ContainerName -name $_.Name -unInstall -doNotSaveData -doNotSaveSchema -force
    }
}

# Import test data
try {
    $repoVersion = Get-ConfigValue -ConfigType "AL-GO" -Key "RepoVersion"
    $DemoDataType = "EXTENDED"

    Write-Host "Initializing company"
    Invoke-NavContainerCodeunit -Codeunitid 2 -containerName $containerName -CompanyName (Get-NavDefaultCompanyName)

    Write-Host "Importing configuration package"
    Invoke-NavContainerCodeunit -Codeunitid 8620 -containerName $containerName -CompanyName (Get-NavDefaultCompanyName) -MethodName "ImportAndApplyRapidStartPackage" -Argument "C:\ConfigurationPackages\NAV$($repoVersion).W1.ENU.$($DemoDataType).rapidstart"
} catch {
    Write-Host "Error while importing configuration package"
    Write-Host $_.Exception.Message
    Write-Host $_.Exception.StackTrace
    exit 1
}