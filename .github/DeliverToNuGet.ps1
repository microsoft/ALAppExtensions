Param(
    [Hashtable] $parameters
)

function GenerateNuspec
(
    [Parameter(Mandatory=$true)]
    $PackageId,
    [Parameter(Mandatory=$true)]
    $Version,
    [Parameter(Mandatory=$true)]
    $Authors,
    [Parameter(Mandatory=$true)]
    $Owners
)
{
    [xml] $template = '<?xml version="1.0" encoding="utf-8"?>
    <package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
        <metadata>
            <id></id>
            <version></version>
            <title>D365 Business Central — System Modules</title>
            <authors></authors>
            <owners></owners>
            <requireLicenseAcceptance>false</requireLicenseAcceptance>
            <description>System Application and Dev Tools for D365 Business Central</description>
            <summary>
                The package contains app files and source code for System Application, System Application Test libraries and tests, as well as Dev Tools for Dynamics365 Business Central.
            </summary>
        </metadata>
    </package>'

    $template.package.metadata.id = $PackageId
    $template.package.metadata.version = $Version
    $template.package.metadata.authors = $Authors
    $template.package.metadata.owners = $Owners

    return $template
}

function GenerateSourceCodeArchive($AppFile, $ALGoProject, $FoldersLookup)
{
    Import-Module BCContainerHelper -DisableNameChecking 
    Extract-AppFileToFolder -appFilename $AppFile.FullName -generateAppJson

    $extractedAppFileFolder = Get-Item -Path "$($AppFile.FullName).source"
    Write-Host "Extracted $($AppFile.FullName) to $($AppFile.FullName).source"

    try {
        $appJsonFile =  gci -Path $extractedAppFileFolder -Filter "app.json"
        $appName = ($appJsonFile | Get-Content | ConvertFrom-Json).Name

        Write-Host "App name: $appName"
        
        foreach($folder in $FoldersLookup) 
        {
            $currentAppSourcePath = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath "$ALGoProject/$folder" -Resolve 
            Write-Host "Looking in $currentAppSourcePath"

            $currentAppName = (gci -Path $currentAppSourcePath -Filter "app.json" | Get-Content | ConvertFrom-Json).Name
            
            if($currentAppName -eq $appName) {
                $appSourceFolder = ($appFile.FullName -replace ".app$", ".Source")
                New-Item -Path $appSourceFolder -ItemType Directory | Out-Null

                try {
                    # Copy over the source code
                    Copy-Item -Path $currentAppSourcePath/** -Destination $appSourceFolder -Recurse -Force
                    
                    # Copy over the app.json
                    Copy-Item -Path "$extractedAppFileFolder/app.json" -Destination $appSourceFolder -Force
                    
                    # Copy over the Translations folder
                    if(Test-Path "$extractedAppFileFolder/Translations") {
                        Copy-Item -Path "$extractedAppFileFolder/Translations" -Destination $appSourceFolder -Container -Force
                    }
                    
                    Compress-Archive -Path $appSourceFolder/** -DestinationPath "$appSourceFolder.zip" -Force

                    $sourceCodeArchive = Get-Item -Path "$appSourceFolder.zip"

                    return $appName, $sourceCodeArchive
                }
                finally {
                    Remove-Item -Path $appSourceFolder -Force -Recurse
                }
            }
        }
    }
    finally {
        Remove-Item -Path $extractedAppFileFolder -Force -Recurse
    }
}

try {
    $nuGetAccount = $parameters.Context | ConvertFrom-Json | ConvertTo-HashTable
    $nuGetServerUrl = $nuGetAccount.ServerUrl
    $nuGetToken = $nuGetAccount.Token
}
catch {
    throw "NuGetContext secret is malformed. Needs to be formatted as JSON, containing serverUrl and token."
}

if (-not ($nuGetServerUrl)) {
    throw "Cannot retrieve NuGet server URL from NuGetContext"
} 

if (-not $nuGetToken) {
    throw "Cannot retrieve NuGet token  URL from NuGetContext"
} 

Write-Host "Successfully retrieved information from NuGetContext" -ForegroundColor Green

$project = $parameters.project
$projectName = $parameters.projectName
$appsFolder = $parameters.appsFolder
$testAppsFolder = $parameters.testAppsFolder
$type = $parameters.type

# Construct package ID
$packageId = "$($env:GITHUB_REPOSITORY_OWNER)-$($env:RepoName)"

if (-not $project -or ($project -ne '.')) {
    $packageId += "-$projectName"
}

if ($type -eq 'CD') {
    $packageId += "-preview"
}

# Extract version from the published folders (naming convention)
$packageVersion = $appsFolder.SubString($appsFolder.IndexOf("-Apps-") + "-Apps-".Length) #version is right after '-Apps-'

$nuspec = GenerateNuspec `
            -PackageId $packageId `
            -Version $packageVersion `
            -Authors "$env:GITHUB_REPOSITORY_OWNER" `
            -Owners "$env:GITHUB_REPOSITORY_OWNER"

# Create a temp folder to use for the packaging
$packageFolder = Join-Path $env:TEMP ([GUID]::NewGuid().ToString())
New-Item -Path $packageFolder -ItemType Directory | Out-Null

Write-Host "Package folder: $packageFolder" -ForegroundColor Magenta

try {
    $appFiles = gci -Path $appsFolder -Filter "*.app"
    $appFiles | % {
        $appFile = $_
        Write-Host "Processing $($appFile.FullName)" -ForegroundColor Magenta

        $appName, $sourceCodeArchive = GenerateSourceCodeArchive -AppFile $appFile -ALGoProject $project -FoldersLookup @($($parameters.projectSettings.appFolders))

        New-Item -Path "$packageFolder/Apps/$appName" -ItemType Directory -Force
        Copy-Item -Path $appFile.FullName -Destination "$packageFolder/Apps/$appName" -Force
        Copy-Item -Path $sourceCodeArchive.FullName -Destination "$packageFolder/Apps/$appName" -Force
    }
    
    $testAppFiles = gci -Path $testAppsFolder -Filter "*.app"
    $testAppFiles | % {
        $appFile = $_
        Write-Host "Processing $($appFile.FullName)" -ForegroundColor Magenta

        $appName, $sourceCodeArchive = GenerateSourceCodeArchive -AppFile $appFile -ALGoProject $project -FoldersLookup @($($parameters.projectSettings.testFolders))

        New-Item -Path "$packageFolder/Test Apps/$appName" -ItemType Directory -Force
        Copy-Item -Path $appFile.FullName -Destination "$packageFolder/Test Apps/$appName" -Force
        Copy-Item -Path $sourceCodeArchive.FullName -Destination "$packageFolder/Test Apps/$appName" -Force
    }
    
    #Create .nuspec file
    $nuspecFilePath = (Join-Path $packageFolder 'manifest.nuspec')
    $nuspec.Save($nuspecFilePath)
    
    $outputDirectory = Join-Path $env:GITHUB_WORKSPACE 'out'
    New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null

    Write-Host "Download nuget CLI" -ForegroundColor Magenta
    Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile $outputDirectory/nuget.exe
    
    $nugetOutput =  Invoke-Expression -Command "$outputDirectory/nuget.exe pack $nuspecFilePath -OutputDirectory $outputDirectory"
    
    $nugetOutput | Write-Host -ForegroundColor Magenta
    if ($LASTEXITCODE -or $null -eq $nugetOutput)
    {
        throw "Generating the nuget pack failed with exit code $LASTEXITCODE"
    }
    
    # Get the newly created package
    $nugetPackageFile = gci -Path $outputDirectory -Filter "$packageId*.nupkg"

    if(-not $nugetPackageFile) {
        throw "Cannot find nupkg file in $outputDirectory"
    }

    Write-Host "Push package $($nugetPackageFile.FullName) to $nuGetServerUrl" -ForegroundColor Magenta
    $nugetOutput =  Invoke-Expression -Command "$outputDirectory/nuget.exe push $($nugetPackageFile.FullName) -ApiKey $nuGetToken -Source $nuGetServerUrl"

    if ($LASTEXITCODE -or $null -eq $nugetOutput)
    {
        throw "Pushing nuget package $($nugetPackageFile.FullName) failed with exit code $LASTEXITCODE"
    }
}
finally {
    Remove-Item $packageFolder -Recurse -Force
}
