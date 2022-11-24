Param(
    [Hashtable] $parameters
)

$appName = (gci -Path $($parameters.appProjectFolder) -Filter "app.json" | Get-Content | ConvertFrom-Json).name

$parameters.appOutputFolder = Join-Path -Path $parameters.appOutputFolder -ChildPath $appName

if (!$parameters.ContainsKey("Features")) {
    $parameters["Features"] = @()
}
$parameters["Features"] = @("lcgtranslationfile", "generateCaptions")

$appFile = Compile-AppInBcContainer @parameters

Write-Host "Archive the current source code for app: $appName in $($parameters.appOutputFolder)"
Compress-Archive -Path "$($parameters.appProjectFolder)" -DestinationPath "$($parameters.appOutputFolder)/$appName.Source.zip" -Force

$appFile