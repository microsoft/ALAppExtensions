Param(
    [Parameter(Mandatory=$true)]
    [string] $BuildArtifactsPath,
    [Parameter(Mandatory=$true)]
    [string] $OutputPackageFolder,
    [Parameter(Mandatory=$true)]
    [string] $RepoName,
    [Parameter(Mandatory=$true)]
    [string] $RepoOwner,
    [Parameter(Mandatory=$true)]
    [string] $NuspecPath,
    [Parameter(Mandatory=$true)]
    [string] $LicensePath
)

function GenerateManifest
(
    [Parameter(Mandatory=$true)]
    $PackageId,
    [Parameter(Mandatory=$true)]
    $Version,
    [Parameter(Mandatory=$true)]
    $Authors,
    [Parameter(Mandatory=$true)]
    $Owners,
    [Parameter(Mandatory=$true)]
    $NuspecPath,
    [Parameter(Mandatory=$true)]
    $OutputPath
)
{
    [xml] $template = Get-Content $NuspecPath

    $template.package.metadata.id = $PackageId
    $template.package.metadata.version = $Version
    $template.package.metadata.authors = $Authors
    $template.package.metadata.owners = $Owners

    Write-Host "Generating manifest file: $OutputPath" -ForegroundColor Magenta
    $template.Save($OutputPath)
}

function PreparePackageFolder
(
    [Parameter(Mandatory=$true)]
    $OutputPackageFolder,
    [Parameter(Mandatory=$true)]
    $AppFolders,
    [Parameter(Mandatory=$true)]
    $LicensePath
)
{
    New-Item -Path "$OutputPackageFolder/Apps" -ItemType Directory -Force | Out-Null
    $AppFolders | ForEach-Object { 
        $appsToPackage = Join-Path $_.FullName 'Package'
        Write-Host "Copying apps from $appsToPackage" -ForegroundColor Magenta
        
        if(Test-Path -Path $appsToPackage) 
        {
            Copy-Item -Path "$appsToPackage/*" -Destination "$OutputPackageFolder/Apps" -Recurse -Force
        } else {
            throw "No apps found in: $appsToPackage" 
        }
    }

    # Copy over the license file
    Copy-Item -Path $LicensePath -Destination $OutputPackageFolder -Force
}

New-Item -Path $OutputPackageFolder -ItemType Directory | Out-Null

$appsFolders = Get-ChildItem $BuildArtifactsPath -Directory 
$packageVersion = ($appsFolders -replace ".*-Apps-","" | Select-Object -First 1).ToString() 
$packageId = "$RepoOwner-$RepoName-Modules-preview"

Write-Host "App folder(s): $($appsFolders -join ', ')" -ForegroundColor Magenta
Write-Host "Package folder: $OutputPackageFolder" -ForegroundColor Magenta
Write-Host "Package ID: $packageId" -ForegroundColor Magenta
Write-Host "Package version: $packageVersion" -ForegroundColor Magenta

# Generate Nuspec file
$manifestOutputPath = (Join-Path $OutputPackageFolder 'manifest.nuspec')
GenerateManifest `
    -PackageId $packageId `
    -Version $packageVersion `
    -Authors "$RepoOwner" `
    -Owners "$RepoOwner" `
    -NuspecPath $NuspecPath `
    -OutputPath $manifestOutputPath

# Copy files to package folder
PreparePackageFolder -OutputPackageFolder $OutputPackageFolder -AppFolders $appsFolders -LicensePath $LicensePath

# Pack Nuget package
nuget pack $manifestOutputPath -OutputDirectory $OutputPackageFolder