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

Write-Host "Current app name: $appName"

# Create an archive with the current source code in the build artifacts folder

$archiveFile = "($env:TEMP)/$appName.Source.zip"
Write-Host "Archive the current source code for app: $appName as $archiveFile"
Compress-Archive -Path "$($parameters.appProjectFolder)" -DestinationPath "($env:TEMP)/$appName.Source.zip" -Force

$buildArtifactsFolder = ".buildartifacts/Apps"

if(-not (Test-Path $($parameters.appProjectFolder)/$buildArtifactsFolder)) {
    Write-Host "Creating $buildArtifactsFolder in $($parameters.appProjectFolder)"
    New-Item -Path $($parameters.appProjectFolder) -Name $buildArtifactsFolder -ItemType Directory
}

Move-Item -Path $archiveFile -Destination "$($parameters.appProjectFolder)/$buildArtifactsFolder" -Force

$appFile