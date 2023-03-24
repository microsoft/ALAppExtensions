class ApplicationPackageMetadata
{
    [string] $ApplicationName
    [bool] $IncludeInPackage
}

class PackageMetadata 
{
    [string] $LicensePath
    [string] $NuspecPath
    [ApplicationPackageMetadata[]] $Applications
}

<#
.Synopsis
    Get package metadata from the Package.json file
#>
function Get-PackageMetadata() {
    Import-Module "$PSScriptRoot\..\EnlistmentHelperFunctions.psm1"

    $baseFolder = Get-BaseFolder
    $packageMetadataJson = (Get-Content "$PSScriptRoot\Package.json" | ConvertFrom-Json)
   
    [PackageMetadata] $packageMetadata = [PackageMetadata]::new()
    $packageMetadata.LicensePath = (Join-Path $baseFolder $packageMetadataJson.LicensePath -Resolve)
    $packageMetadata.NuspecPath = (Join-Path $baseFolder $packageMetadataJson.NuspecPath -Resolve)

    $packageMetadata.Applications = @()
    ($packageMetadataJson.Projects | Get-Member -MemberType NoteProperty).Name | ForEach-Object {
        $applicationName = $_

        $applicationPackageMetadata = [ApplicationPackageMetadata]::new()
        $applicationPackageMetadata.ApplicationName = $applicationName
        $applicationPackageMetadata.IncludeInPackage = $packageMetadataJson.Projects.$applicationName.includeInPackage
        $packageMetadata.Applications += $applicationPackageMetadata
    }

    return $packageMetadata
}

<#
.Synopsis
    Copies the apps from the build artifacts folder to the package folder
.Parameter OutputPackageFolder
    The path to the package folder
.Parameter AppFolders
    The list of app folders to copy from
.Parameter ApplicationsToPackage
    The list of applications to package
.Parameter LicensePath
    The path to the license file
#>
function Initialize-PackageFolder
(
    [Parameter(Mandatory=$true)]
    $OutputPackageFolder,
    [Parameter(Mandatory=$true)]
    $AppFolders,
    [Parameter(Mandatory=$true)]
    $ApplicationsToPackage,
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
            $ApplicationsToPackage | ForEach-Object {
                $applicationName = $_.ApplicationName
                if (Test-Path "$appsToPackage/$applicationName") {
                    Copy-Item -Path "$appsToPackage/$applicationName" -Destination "$OutputPackageFolder/Apps" -Recurse -Force
                }
            }
        } else {
            Write-Host "No apps found in: $appsToPackage" 
        }
    }

    # Copy over the license file
    Copy-Item -Path $LicensePath -Destination $OutputPackageFolder -Force
}

<#
.Synopsis
    Verifies that all expected apps are in the package folder
.Parameter OutputPackageFolder
    The path to the package folder
.Parameter ExpectedApplications
    The list of expected applications
#>
function Test-PackageFolder
(
    [Parameter(Mandatory=$true)]
    $OutputPackageFolder,
    [Parameter(Mandatory=$true)]
    $ExpectedApplications
) 
{
    $appsFolder = Join-Path $OutputPackageFolder "Apps" -Resolve
    $appsInPackageFolder = Get-ChildItem -Path $appsFolder

    if($appsInPackageFolder.Count -eq 0) {
        throw "No apps found in $appsInPackageFolder"
    } 

    Write-Host "Verifying expected apps are in package folder"
    $ExpectedApplications | ForEach-Object {
        $applicationName = $_.ApplicationName
        if (-not (Test-Path -Path "$appsFolder/$applicationName")) {
            throw "App $applicationName not found in $appsFolder"
        }
    }

    Write-Host "Verifying apps in package folder are expected"
    $appsInPackageFolder | ForEach-Object {
        $applicationName = $_.Name
        if (-not ($ExpectedApplications | Where-Object ApplicationName -eq $applicationName)) {
            throw "App $applicationName not expected in $appsFolder"
        }
    }
}

<#
.Synopsis 
    Generates a manifest file for the package
.Parameter PackageId
    The package id
.Parameter Version
    The package version
.Parameter Authors
    The package authors
.Parameter Owners
    The package owners
.Parameter NuspecPath
    The path to the nuspec template file
.Parameter OutputPath
    The path to the output manifest file
#>
function New-Manifest
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

Export-ModuleMember *-*
