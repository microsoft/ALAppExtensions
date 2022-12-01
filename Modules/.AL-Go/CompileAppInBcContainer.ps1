Param(
    [Hashtable] $parameters
)

# Setup compiler features to generate captions and LCGs
if (!$parameters.ContainsKey("Features")) {
    $parameters["Features"] = @()
}
$parameters["Features"] += @("lcgtranslationfile", "generateCaptions")

$appFile = Compile-AppInBcContainer @parameters

$branchName = $ENV:GITHUB_REF_NAME

# Only add the source code to the build artifacts if the delivering is allowed on the branch 
if(($branchName -eq 'main') -or $branchName.StartsWith('release/')) {
    $appProjectFolder = $parameters.appProjectFolder

    # Extract app name from app.json
    $appName = (gci -Path $appProjectFolder -Filter "app.json" | Get-Content | ConvertFrom-Json).name

    Write-Host "Current app name: $appName; app folder: $appProjectFolder"

    # TODO there must be a better way :D
    $holderFolder = 'TestApps'
    if($appName -eq "System Application") {
        $holderFolder = 'Apps'
    }

    $packageArtifactsFolder = "$env:GITHUB_WORKSPACE/Modules/.buildartifacts/$holderFolder/Package/$appName" # hackidy-hack

    if(-not (Test-Path $packageArtifactsFolder)) {
        Write-Host "Creating $packageArtifactsFolder"
        New-Item -Path "$env:GITHUB_WORKSPACE/Modules" -Name ".buildartifacts/$holderFolder/Package/$appName" -ItemType Directory | Out-Null
    }

    Write-Host "Package artifacts folder: $packageArtifactsFolder"

    Copy-Item -Path $appProjectFolder -Destination $packageArtifactsFolder -Recurse -Force | Out-Null
    Copy-Item -Path $appFile -Destination $packageArtifactsFolder -Force | Out-Null
}

$appFile