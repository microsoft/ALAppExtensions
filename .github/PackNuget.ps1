
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

$buildArtifactsPath = Join-Path $env:GITHUB_WORKSPACE '.artifacts'
$packageFolder = Join-Path $env:GITHUB_WORKSPACE 'out'

$projectName = "Modules" 
$appsFolders = Get-ChildItem $buildArtifactsPath -Directory | where-object {$_.FullName.Contains("Apps-")} | Select-Object -ExpandProperty FullName
$testAppsFolders = Get-ChildItem $buildArtifactsPath -Directory | where-object {$_.FullName.Contains("TestApps-")} | Select-Object -ExpandProperty FullName
$packageVersion = ($appsFolders -replace ".*-Apps-","" | Select-Object -First 1).ToString() 

Write-Host "App folder(s): $($appsFolders -join ', ')" -ForegroundColor Magenta
Write-Host "Test app folder(s): $($testAppsFolders -join ', ')" -ForegroundColor Magenta


### Generate Nuspec file
# Construct package ID
$RepoName = $env:GITHUB_REPOSITORY -replace "/", "-"
if ($ENV:GITHUB_REF_NAME -eq "main") {
    $packageId = "$RepoName-$projectName-preview"
} else {
    $packageId = "$RepoName-$projectName-test"
}

Write-Host "Package ID: $packageId" -ForegroundColor Magenta
Write-Host "Package version: $packageVersion" -ForegroundColor Magenta

$manifest = GenerateManifest `
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
Copy-Item -Path "$env:GITHUB_WORKSPACE/LICENSE" -Destination "$packageFolder" -Force

#Create .nuspec file
$manifestFilePath = (Join-Path $packageFolder 'manifest.nuspec')
$manifest.Save($manifestFilePath)

nuget pack $manifestFilePath -OutputDirectory $packageFolder