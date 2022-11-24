Param(
    [Hashtable] $parameters
)

if (!$parameters.ContainsKey("Features")) {
    $parameters["Features"] = @()
}
$parameters["Features"] = @("lcgtranslationfile", "generateCaptions")

$appFile = Compile-AppInBcContainer @parameters

Write-Host "Archive the current source code for app: $($parameters.appName) in $($parameters.appOutputFolder)"
Compress-Archive -Path "$($parameters.appProjectFolder)" -DestinationPath "$($parameters.appOutputFolder)/$($parameters.appName).zip" -Force

$appFile