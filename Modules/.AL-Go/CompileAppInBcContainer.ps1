Param(
    [Hashtable] $parameters
)


function Get-Baselines {
    Param(
    [string] $BaselineVersion = "21.4.52563.53749",
    [string] $ApplicationName = "System Application",
    [string] $PackageCacheFolder
)
    if(-not $BaselineVersion) {
        Write-Host "Baseline version is not defined"
    }
    else {
        Write-Host "Baseline version: $BaselineVersion"

        $baselineURL = Get-BCArtifactUrl -type Sandbox -country 'W1' -version $BaselineVersion # W1 because Modules are not localized
        if(-not $baselineURL) {
            throw "Unable to find URL for baseline version $BaselineVersion"
        }
        $baselineFolder = Join-Path $([System.IO.Path]::GetTempPath()) 'baselines'
        
        Write-Host "Baseline URL: $baselineURL"
        Write-Host "Downloading to: $baselineFolder"
        
        Download-Artifacts -artifactUrl $baselineURL -basePath $baselineFolder
        $baselineApp = Get-ChildItem -Path "$baselineFolder/sandbox/$BaselineVersion/w1/Extensions/*$ApplicationName*" -Filter "*.app"


        Write-Host "Container Name: $($parameters.ContainerName)"
        Write-Host "appSymbolsFolder: $($parameters["appSymbolsFolder"])"

        $containerSymbolsFolder = Get-BcContainerPath -containerName $parameters.ContainerName -path $parameters["appSymbolsFolder"]

        Write-Host "Container Symbols Folder: $containerSymbolsFolder"

        Write-Host "Copying $($baselineApp.FullName) to $containerSymbolsFolder in container $($parameters.ContainerName)"

        Copy-FileToBcContainer -containerName $parameters.ContainerName -localPath $baselineApp.FullName -containerPath $containerSymbolsFolder

        if (!(Test-Path $PackageCacheFolder)) {
            Write-Host "Creating $PackageCacheFolder"
            New-Item -Path $PackageCacheFolder -ItemType Directory -Force
        }

        Copy-Item -Path $baselineApp.FullName -Destination $PackageCacheFolder -Force -Verbose
        $Items = Get-ChildItem -Path $PackageCacheFolder -Recurse
        Write-host "Child Items:"
        Write-host $Items

        Remove-Item -Path $baselineFolder -Recurse -Force -Verbose
    }
}


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

Write-Host $parameters
Write-Host $parameters["appSymbolsFolder"]
Write-Host $parameters['appProjectFolder']

<#if (!$parameters.ContainsKey("appSymbolsFolder")) {
    $parameters["appSymbolsFolder"] = Join-Path $parameters['appProjectFolder'] ".alpackages"
}#>

Get-Baselines -PackageCacheFolder $parameters["appSymbolsFolder"]

$appFile = Compile-AppInBcContainer @parameters

$branchName = $ENV:GITHUB_REF_NAME

# Only add the source code to the build artifacts if the delivering is allowed on the branch 
if($branchName -and (($branchName -eq 'main') -or $branchName.StartsWith('release/'))) {
    $appProjectFolder = $parameters.appProjectFolder
    
    # Extract app name from app.json
    $appName = (Get-ChildItem -Path $appProjectFolder -Filter "app.json" | Get-Content | ConvertFrom-Json).name

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