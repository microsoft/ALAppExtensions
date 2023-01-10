
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

    $template.Save("$PSScriptRoot\ALAppExtensions.template.nuspec")
}

$buildArtifactsPath = Join-Path $env:GITHUB_WORKSPACE '.artifacts'
$packageFolder = Join-Path $env:GITHUB_WORKSPACE 'out'

$projectName = "Modules" 
$appsFolders = Get-ChildItem $buildArtifactsPath -Directory | where-object {$_.FullName.Contains("Apps-")} | Select-Object -ExpandProperty FullName
$testAppsFolders = Get-ChildItem $buildArtifactsPath -Directory | where-object {$_.FullName.Contains("TestApps-")} | Select-Object -ExpandProperty FullName
$packageVersion = ($appsFolders -replace ".*-Apps-","" | Select-Object -First 1).ToString() #version is right after '-Apps-'

Write-Host "App folder(s): $($appsFolders -join ', ')" -ForegroundColor Magenta
Write-Host "Test app folder(s): $($testAppsFolders -join ', ')" -ForegroundColor Magenta


### Generate Nuspec file
# Construct package ID
if ($ENV:GITHUB_REF_NAME -eq "main") {
    $packageId = "$($env:GITHUB_REPOSITORY_OWNER)-$($env:RepoName)-$projectName-preview"
} else {
    $packageId = "$($env:GITHUB_REPOSITORY_OWNER)-$($env:RepoName)-$projectName-test"
}

Write-Host "Package ID: $packageId" -ForegroundColor Magenta
Write-Host "Package version: $packageVersion" -ForegroundColor Magenta

GenerateManifest `
    -PackageId $packageId `
    -Version $packageVersion `
    -Authors "$env:GITHUB_REPOSITORY_OWNER" `
    -Owners "$env:GITHUB_REPOSITORY_OWNER"

### Copy files to package folder
New-Item -Path $packageFolder -ItemType Directory | Out-Null
Write-Host "Package folder: $packageFolder" -ForegroundColor Magenta

# Create folder to hold the apps
New-Item -Path "$packageFolder/Apps" -ItemType Directory -Force | Out-Null

@($appsFolders) + @($testAppsFolders) | ForEach-Object { 
    $appsToPackage = Join-Path $_ 'Package'
    
    if(Test-Path -Path $appsToPackage) 
    {
        Copy-Item -Path "$appsToPackage/*" -Destination "$packageFolder/Apps" -Recurse -Force
    }
}

# Copy over the license file
Copy-Item -Path "$env:GITHUB_WORKSPACE/LICENSE" -Destination "$packageFolder/Apps" -Force