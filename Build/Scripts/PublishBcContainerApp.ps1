Param([Hashtable]$parameters)

Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1

$appShouldBeSkipped = (Get-ConfigValue -ConfigType "BuildConfig" -Key "AppsNotToBePublished") | Where-Object {
    return $parameters["appFile"] -like "*$($_)*.app"
}

if ($appShouldBeSkipped) {
    Write-Host "Skipping publishing of app $($parameters['appFile']) because it is in the list of apps not to be published."
    return
} else {
    Write-Host "Publishing app $($parameters['appFile'])"
    Publish-BcContainerApp @parameters
}
