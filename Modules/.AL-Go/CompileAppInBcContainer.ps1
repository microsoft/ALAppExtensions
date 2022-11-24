Param(
    [Hashtable] $parameters
)

# Setup compiler features to generate captions and LCGs
if (!$parameters.ContainsKey("Features")) {
    $parameters["Features"] = @()
}
$parameters["Features"] = @("lcgtranslationfile", "generateCaptions")

$appFile = Compile-AppInBcContainer @parameters

# Extract app name from app.json
$appName = (gci -Path $($parameters.appProjectFolder) -Filter "app.json" | Get-Content | ConvertFrom-Json).name

# Create an archive with the current source code in the build artifacts folder
$buildArtifactsFolder = Join-Path -Path $parameters.appProjectFolder -ChildPath ".buildartifacts/Apps"

Write-Host "Archive the current source code for app: $appName in $buildArtifactsFolder"
Compress-Archive -Path "$($parameters.appProjectFolder)" -DestinationPath "$buildArtifactsFolder/$appName.Source.zip" -Force

$appFile