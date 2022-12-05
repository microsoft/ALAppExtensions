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
    $parameters["Features"] += @("lcgtranslationfile", "generateCaptions")    
}

$appFile = Compile-AppInBcContainer @parameters

$branchName = $ENV:GITHUB_REF_NAME

$appProjectFolder = $parameters.appProjectFolder

# Extract app name from app.json
$appName = (gci -Path $appProjectFolder -Filter "app.json" | Get-Content | ConvertFrom-Json).name

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

Copy-Item -Path $appProjectFolder -Destination "$packageArtifactsFolder/SourceCode" -Recurse -Force | Out-Null
Copy-Item -Path $appFile -Destination $packageArtifactsFolder -Force | Out-Null

$appFile