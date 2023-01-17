Param(
    [Parameter(Mandatory=$true)]
    [string] $BuildArtifactsPath,
    [Parameter(Mandatory=$true)]
    [string] $OutputPackageFolder,
    [string] $RepoName,
    [string] $RepoOwner,
    [string] $RepoRoot
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
    $Owners
)
{
    [xml] $template = Get-Content "$PSScriptRoot\ALAppExtensions.template.nuspec"

    $template.package.metadata.id = $PackageId
    $template.package.metadata.version = $Version
    $template.package.metadata.authors = $Authors
    $template.package.metadata.owners = $Owners

    return $template
}

New-Item -Path $OutputPackageFolder -ItemType Directory | Out-Null

$appsFolders = Get-ChildItem $BuildArtifactsPath -Directory 
$packageVersion = ($appsFolders -replace ".*-Apps-","" | Select-Object -First 1).ToString() 

Write-Host "App folder(s): $($appsFolders -join ', ')" -ForegroundColor Magenta

# Generate Nuspec file
$projectName = "Modules" 
$packageId = "$RepoName-$projectName-preview"

Write-Host "Package ID: $packageId" -ForegroundColor Magenta
Write-Host "Package version: $packageVersion" -ForegroundColor Magenta

$manifest = GenerateManifest `
            -PackageId $packageId `
            -Version $packageVersion `
            -Authors "$RepoOwner" `
            -Owners "$RepoOwner"

#Save .nuspec file
$manifestFilePath = (Join-Path $OutputPackageFolder 'manifest.nuspec')
$manifest.Save($manifestFilePath)

### Copy files to package folder
Write-Host "Package folder: $OutputPackageFolder" -ForegroundColor Magenta
New-Item -Path "$OutputPackageFolder/Apps" -ItemType Directory -Force | Out-Null
$appsFolders | ForEach-Object { 
    $appsToPackage = Join-Path $_ 'Package'
    
    if(Test-Path -Path $appsToPackage) 
    {
        Copy-Item -Path "$appsToPackage/*" -Destination "$OutputPackageFolder/Apps" -Recurse -Force
    }
}

# Copy over the license file
Copy-Item -Path "$RepoRoot/LICENSE" -Destination "$OutputPackageFolder" -Force

nuget pack $manifestFilePath -OutputDirectory $OutputPackageFolder