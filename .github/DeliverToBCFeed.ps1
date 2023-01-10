Param(
    [Hashtable] $parameters
)
<#
$project = "$parameters.project"
$projectName = "Modules"
$appsFolders = $parameters.appsFolders
$testAppsFolders = $parameters.testAppsFolders
#>
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

Write-Host $parameters -ForegroundColor Magenta

$project = $parameters.project
$projectName = $parameters.projectName
$appsFolders = $parameters.appsFolders
$testAppsFolders = $parameters.testAppsFolders

Write-Host "App folder(s): $($appsFolders -join ', ')" -ForegroundColor Magenta
Write-Host "Test app folder(s): $($testAppsFolders -join ', ')" -ForegroundColor Magenta

$artifactsPath = Join-Path $env:GITHUB_WORKSPACE '.artifacts'

if (test-path $artifactsPath) {
    $testAppsFolders2 = Get-ChildItem $artifactsPath -Directory | where-object {$_.FullName.Contains("TestApps-")} | Select-Object -ExpandProperty FullName
    $AppsFolders2 = Get-ChildItem $artifactsPath -Directory | where-object {$_.FullName.Contains("Apps-")} | Select-Object -ExpandProperty FullName

    Write-Host "App folder(s) 2: $($AppsFolders2 -join ', ')" -ForegroundColor Magenta
    Write-Host "Test app folder(s) 2: $($testAppsFolders2 -join ', ')" -ForegroundColor Magenta

} else {
    Write-Host "No artifacts folder found in path $artifactsPath" -ForegroundColor Magenta
}

# Construct package ID
if ($ENV:GITHUB_REF_NAME -eq "main") {
    $packageId = "$($env:GITHUB_REPOSITORY_OWNER)-$($env:RepoName)-$projectName-preview"
} else {
    $packageId = "$($env:GITHUB_REPOSITORY_OWNER)-$($env:RepoName)-$projectName-test"
}

Write-Host "Package ID: $packageId" -ForegroundColor Magenta

# Extract version from the published folders (naming convention)
$packageVersion = ($appsFolders -replace ".*-Apps-","" | Select-Object -First 1).ToString() #version is right after '-Apps-'

Write-Host "Package version: $packageVersion" -ForegroundColor Magenta

$manifest = GenerateManifest `
            -PackageId $packageId `
            -Version $packageVersion `
            -Authors "$env:GITHUB_REPOSITORY_OWNER" `
            -Owners "$env:GITHUB_REPOSITORY_OWNER"

# Create a temp folder to use for the packaging
$packageFolder = Join-Path $env:GITHUB_WORKSPACE 'out'
#$packageFolder = Join-Path $env:TEMP ([GUID]::NewGuid().ToString())
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

#Create .nuspec file
$manifest.Save("$PSScriptRoot\ALAppExtensions.template.nuspec")
