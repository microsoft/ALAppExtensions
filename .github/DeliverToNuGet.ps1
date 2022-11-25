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
    $outputDirectory = Join-Path $env:GITHUB_WORKSPACE 'out'
    New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null

    $appsPackage = Join-Path $appsFolder 'Package'
    if(Test-Path -Path "$appsPackage") {
        Copy-Item -Path "$appsPackage/**" -Destination "$packageFolder/Apps/" -Recurse -Container -Force
    }

    $testAppsPackage = Join-Path $testAppsFolder 'Package'
    if(Test-Path -Path "$testAppsPackage") {
        Copy-Item -Path "$testAppsPackage/**" -Destination "$packageFolder/Tests/" -Recurse -Container -Force
    }
    
    #Create .nuspec file
    $nuspecFilePath = (Join-Path $packageFolder 'manifest.nuspec')
    $nuspec.Save($nuspecFilePath)

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
