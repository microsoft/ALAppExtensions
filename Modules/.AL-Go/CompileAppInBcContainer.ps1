Param(
    [Hashtable] $parameters
)

$appName = (gci -Path $($parameters.appProjectFolder) -Filter "app.json" | Get-Content | ConvertFrom-Json).name

$buildArtifactsFolder = Join-Path -Path $parameters.appOutputFolder -ChildPath ".buildartifacts/Apps"

if (!$parameters.ContainsKey("Features")) {
    $parameters["Features"] = @()
}
$parameters["Features"] = @("lcgtranslationfile", "generateCaptions")

$appFile = Compile-AppInBcContainer @parameters

Write-Host "Archive the current source code for app: $appName in $buildArtifactsFolder"
Compress-Archive -Path "$($parameters.appProjectFolder)" -DestinationPath "$buildArtifactsFolder/$appName.Source.zip" -Force

$appFile