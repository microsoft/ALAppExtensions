Param(
    [Hashtable] $parameters
)

# $app is a variable that determine whether the current app is a normal app (not test app, for instance)
if($app)
{
    # Setup compiler features to generate captions and LCGs
    if (!$parameters.ContainsKey("Features")) {
        $parameters["Features"] = @()
    }
    $parameters["Features"] += @("generateCaptions")
}

$appFile = Compile-AppInBcContainer @parameters

$branchName = $ENV:GITHUB_REF_NAME

Write-Host "BuildMode - $ENV:BuildMode"

# Only add the source code to the build artifacts if the delivering is allowed on the branch 
if((($branchName.EndsWith('main')) -or $branchName.StartsWith('release/')) -and ($ENV:BuildMode -eq 'Translated')) {
    $appProjectFolder = $parameters.appProjectFolder

    # Extract app name from app.json
    $appName = (Get-ChildItem -Path $appProjectFolder -Filter "app.json" | Get-Content | ConvertFrom-Json).name

    Write-Host "Current app name: $appName; app folder: $appProjectFolder"

    $holderFolder = 'Apps'
    if(-not $app) {
        $holderFolder = 'TestApps'
    }

    $packageArtifactsFolder = "$env:GITHUB_WORKSPACE/Modules/.buildartifacts/$holderFolder/Package/$appName" # manually construct the artifacts folder

    if(-not (Test-Path $packageArtifactsFolder)) {
        Write-Host "Creating $packageArtifactsFolder"
        New-Item -Path "$env:GITHUB_WORKSPACE/Modules" -Name ".buildartifacts/$holderFolder/Package/$appName" -ItemType Directory | Out-Null
    }

    Write-Host "Package artifacts folder: $packageArtifactsFolder"

    # Add the source code and the app file for every built app to a folder
    Copy-Item -Path $appProjectFolder -Destination "$packageArtifactsFolder/SourceCode" -Recurse -Force | Out-Null
    Copy-Item -Path $appFile -Destination $packageArtifactsFolder -Force | Out-Null
}

$appFile