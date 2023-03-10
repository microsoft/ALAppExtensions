Param(
    [Parameter(Mandatory=$true)]
    [string] $currentProjectFolder,
    [Hashtable] $parameters
)

Write-Host "BuildMode - $ENV:BuildMode"
$appBuildMode = $ENV:BuildMode

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
}

$appFile = Compile-AppInBcContainer @parameters

$branchName = $ENV:GITHUB_REF_NAME

# Only add the source code and other artifacts to the build artifacts if the delivering is allowed on the branch 
if($branchName -and (($branchName -eq 'build-app-modules') -or $branchName.StartsWith('release/'))) {
    $appProjectFolder = $parameters.appProjectFolder
    
    # Extract app name from app.json
    $appName = (Get-ChildItem -Path $appProjectFolder -Filter "app.json" | Get-Content | ConvertFrom-Json).name

    Write-Host "Current app name: $appName; app folder: $appProjectFolder"

    # Determine the folder where the artifacts for the package will be stored
    $holderFolder = 'Apps'
    if(-not $app) {
        $holderFolder = 'TestApps'
    }

    $packageArtifactsFolder = "$currentProjectFolder/.buildartifacts/$holderFolder/Package/$appName/$appBuildMode" # manually construct the artifacts folder
    
    
    if(-not (Test-Path $packageArtifactsFolder)) {
        Write-Host "Creating $packageArtifactsFolder"
        New-Item -Path "$currentProjectFolder" -Name ".buildartifacts/$holderFolder/Package/$appName/$appBuildMode" -ItemType Directory | Out-Null
    }
    
    Write-Host "Package artifacts folder: $packageArtifactsFolder"
    
    $buildArtifactsFolder = Join-Path "$packageArtifactsFolder" "BuildArtifacts"
    $sourceCodeFolder = Join-Path "$packageArtifactsFolder" "SourceCode"

    switch ( $appBuildMode )
    {
        'Default' { 
            # Add the generated Translations folder to the artifacts folder
            $TranslationsFolder = Join-Path "$appProjectFolder" "Translations"
            if (Test-Path $TranslationsFolder) {
                Write-Host "Copying translation for app $appName from $TranslationsFolder to $buildArtifactsFolder"
                Copy-Item -Path $TranslationsFolder -Destination "$buildArtifactsFolder" -Recurse -Force | Out-Null
            } else {
                Write-Host "Translations were not generated for app $appName"
            }

            # Add the source code to the artifacts folder
            Write-Host "Copying source code for app '$appName' from '$appProjectFolder' to source code folder: $sourceCodeFolder"
            Copy-Item -Path "$appProjectFolder" -Destination "$sourceCodeFolder" -Recurse -Force | Out-Null
         }
        'Translated' { 
            # Add the source code for non-test apps to the artifacts folder as it contains the translations
            if($app) {
                Write-Host "Copying source code for app '$appName' from '$appProjectFolder' to source code folder: $sourceCodeFolder"
                Copy-Item -Path "$appProjectFolder" -Destination "$sourceCodeFolder" -Recurse -Force | Out-Null
            }
        }
    }
    
    # Add the app file for every built app to a folder for all built modes
    Write-Host "Copying app file for app '$appName' from '$appFile' to build artifacts folder: $packageArtifactsFolder"
    Copy-Item -Path $appFile -Destination $packageArtifactsFolder -Force | Out-Null
}

$appFile