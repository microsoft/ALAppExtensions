Param(
    [Hashtable] $parameters
)

Write-Host "BuildMode - $ENV:BuildMode"
$appBuildMode = $ENV:BuildMode

# Extract app properties from app.json
$appProjectFolder = $parameters.appProjectFolder
$appJson = Get-ChildItem -Path $appProjectFolder -Filter "app.json" | Get-Content | ConvertFrom-Json

$appName = $appJson.name
$appVersion = $appJson.version
$appPublisher = $appJson.publisher

# $app is a variable that determine whether the current app is a normal app (not test app, for instance)
if($app)
{
    # Setup compiler features to generate captions and LCGs
    if (!$parameters.ContainsKey("Features")) {
        $parameters["Features"] = @()
    }
    $parameters["Features"] += @("generateCaptions")

    # Setup compiler features to generate LCGs for the default build mode
    if($appBuildMode -eq 'Default') {
        $parameters["Features"] += @("lcgtranslationfile")
    }

    # Try get baseline
    $baselineFolder = Join-Path $([System.IO.Path]::GetTempPath()) 'baselines'

    $baseline = Get-ChildItem -Path $baselineFolder -Filter "$appPublisher*$appName*.app" -Recurse | Select-Object -First 1

    if($baseline) {
        Write-Host "Using baseline: $($baseline.Name)"

        Write-Host "Copying baseline to symbols folder $($parameters.appSymbolsFolder)"
        Copy-Item -Path $baseline.FullName -Destination $parameters.appSymbolsFolder -Force | Out-Null
    }
    else {
        Write-Host "No baseline found for $appName" // throw?
    }
}

$appFile = Compile-AppInBcContainer @parameters

$branchName = $ENV:GITHUB_REF_NAME

# Only add the source code to the build artifacts if the delivering is allowed on the branch 
if($branchName -and (($branchName -eq 'main') -or $branchName.StartsWith('release/'))) {
    Write-Host "Current app name: $appName; app folder: $appProjectFolder"

    # Determine the folder where the artifacts for the package will be stored
    $holderFolder = 'Apps'
    if(-not $app) {
        $holderFolder = 'TestApps'
    }

    $packageArtifactsFolder = "$env:GITHUB_WORKSPACE/Modules/.buildartifacts/$holderFolder/Package/$appName/$appBuildMode" # manually construct the artifacts folder

    $buildArtifactsFolder = "$packageArtifactsFolder/BuildArtifacts"
    $sourceCodeFolder = "$packageArtifactsFolder/SourceCode"

    if(-not (Test-Path $packageArtifactsFolder)) {
        Write-Host "Creating $packageArtifactsFolder"
        New-Item -Path "$env:GITHUB_WORKSPACE/Modules" -Name ".buildartifacts/$holderFolder/Package/$appName/$appBuildMode" -ItemType Directory | Out-Null
    }

    Write-Host "Package artifacts folder: $packageArtifactsFolder"

    switch ( $appBuildMode )
    {
        'Default' { 
            # Add the generated Translations folder to the artifacts folder
            $TranslationsFolder = "$appProjectFolder/Translations"
            if (Test-Path $TranslationsFolder) {
                Write-Host "Translations were generated for app $appName"
                Copy-Item -Path $TranslationsFolder -Destination "$buildArtifactsFolder" -Recurse -Force | Out-Null
            } else {
                Write-Host "Translations were not generated for app $appName"
            }

            # Add the source code for test apps to the artifacts folder
            if(-not $app) {
                Copy-Item -Path $appProjectFolder -Destination "$sourceCodeFolder" -Recurse -Force | Out-Null
            }

            # Add  the app file for every built app to a folder
            Copy-Item -Path $appFile -Destination $packageArtifactsFolder -Force | Out-Null
         }
        'Translated' { 
            # Add the source code for non-test apps to the artifacts folder
            if($app) {
                Copy-Item -Path $appProjectFolder -Destination "$sourceCodeFolder" -Recurse -Force | Out-Null
            }

            # Add the app file for every built app to a folder
            Copy-Item -Path $appFile -Destination $packageArtifactsFolder -Force | Out-Null
        }

        'Clean' {
              # Add  the app file for every built app to a folder
              Copy-Item -Path $appFile -Destination $packageArtifactsFolder -Force | Out-Null
        }
    }
}

$appFile