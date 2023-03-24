Param(
    [Parameter(Mandatory=$true)]
    [string] $BuildArtifactsPath,
    [Parameter(Mandatory=$true)]
    [string] $OutputPackageFolder,
    [Parameter(Mandatory=$true)]
    [string] $RepoName,
    [Parameter(Mandatory=$true)]
    [string] $RepoOwner
)

Import-Module "$PSScriptRoot\PackNuget.psm1"

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
$packageMetadata = Get-PackageMetadata

New-Manifest `
    -PackageId $packageId `
    -Version $packageVersion `
    -Authors "$RepoOwner" `
    -Owners "$RepoOwner" `
    -NuspecPath $packageMetadata.NuspecPath `
    -OutputPath $manifestOutputPath

$applicationsToPackage = $packageMetadata.Applications | Where-Object IncludeInPackage

# Copy files to package folder
Initialize-PackageFolder -OutputPackageFolder $OutputPackageFolder -AppFolders $appsFolders -ApplicationsToPackage $applicationsToPackage -LicensePath $packageMetadata.LicensePath

# Verify that all expected packages are in the package folder
Test-PackageFolder -OutputPackageFolder $OutputPackageFolder -ExpectedApplications $applicationsToPackage

# Pack Nuget package
nuget pack $manifestOutputPath -OutputDirectory $OutputPackageFolder