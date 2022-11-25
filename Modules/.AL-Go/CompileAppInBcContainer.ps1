Param(
    [Hashtable] $parameters
)

function FindALGoProject($appProjectFolder)
{
    $currentFolder = Get-Item $appProjectFolder

    do {
        $currentFolder = $currentFolder.Parent
    }
    while(-not (Test-Path "$currentFolder/.AL-Go"))

    return $currentFolder.FullName
}

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


if ($parameters['buildArtifactFolder']) {
    Write-Host "Found artifacts folder in parameters!"
    $buildArtifactsFolder = $parameters['buildArtifactFolder']
}
else {
    $ALGoProjectFolder = FindALGoProject -appProjectFolder $appProjectFolder
    Write-Host "AL-Go project: $ALGoProjectFolder"
    $buildArtifactsFolder = ".buildartifacts/Apps" # hackidy-hack
    
    if(-not (Test-Path "$ALGoProjectFolder/$buildArtifactsFolder")) {
        Write-Host "Creating $buildArtifactsFolder in $ALGoProjectFolder"
        New-Item -Path "$ALGoProjectFolder" -Name $buildArtifactsFolder -ItemType Directory
    }

    $buildArtifactsFolder = "$ALGoProjectFolder/$buildArtifactsFolder"
}

Write-Host "Build artifacts folder: $buildArtifactsFolder"

Move-Item -Path $archiveFile -Destination "$buildArtifactsFolder" -Force

$appFile