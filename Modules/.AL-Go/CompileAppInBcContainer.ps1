Param(
    [Hashtable] $parameters
)

# Setup compiler features to generate captions and LCGs
if (!$parameters.ContainsKey("Features")) {
    $parameters["Features"] = @()
}
$parameters["Features"] = @("lcgtranslationfile", "generateCaptions")

$appFile = Compile-AppInBcContainer @parameters

$appProjectFolder = $parameters.appProjectFolder

# Extract app name from app.json
$appName = (gci -Path $appProjectFolder -Filter "app.json" | Get-Content | ConvertFrom-Json).name

Write-Host "Current app name: $appName; app folder: $appProjectFolder"

# Create an archive with the current source code in the build artifacts folder

$archiveFile = "$env:TEMP/$appName.Source.zip"
Write-Host "Archive the current source code for app: $appName as $archiveFile"
Compress-Archive -Path "$appProjectFolder" -DestinationPath $archiveFile -Force

$buildArtifactsFolder = "$env:GITHUB_WORKSPACE/Modules/.buildartifacts/Apps" # hackidy-hack

if(-not (Test-Path $buildArtifactsFolder)) {
    Write-Host "Creating $buildArtifactsFolder"
    New-Item -Path "$env:GITHUB_WORKSPACE/Modules" -Name ".buildartifacts/Apps" -ItemType Directory
}

Write-Host "Build artifacts folder: $buildArtifactsFolder"

Move-Item -Path $archiveFile -Destination "$buildArtifactsFolder" -Force

$appFile