class ApplicationPackageMetadata
{
    # The name of the application
    [string] $ApplicationName
    # Whether or not to include the application in the package
    [bool] $IncludeInPackage
}


<#
.Synopsis 
    Gets the list of applications to include in the package from the Package.json file
#>
function Get-ApplicationsForPackage() {
    $packageJson = "$PSScriptRoot\Package.json"
    $packages = Get-Content $packageJson | ConvertFrom-Json
    
    $applications = @()
    ($packages | Get-Member -MemberType NoteProperty).Name | ForEach-Object {
        $applicationName = $_
    
        $applicationPackageMetadata = [ApplicationPackageMetadata]::new()
        $applicationPackageMetadata.ApplicationName = $applicationName
        $applicationPackageMetadata.IncludeInPackage = $packages.$applicationName.includeInPackage
        $applications += $applicationPackageMetadata
    }

    return $applications
}

<#
.Synopsis
    Copies the apps from the build artifacts folder to the package folder
.Parameter OutputPackageFolder
    The path to the package folder
.Parameter AppFolders
    The list of app folders to copy from
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
    $LicensePath
)
{
    New-Item -Path "$OutputPackageFolder/Apps" -ItemType Directory -Force | Out-Null
    $AppFolders | ForEach-Object { 
        $appsToPackage = Join-Path $_.FullName 'Package'
        Write-Host "Copying apps from $appsToPackage" -ForegroundColor Magenta
        if(Test-Path -Path $appsToPackage) 
        {
            (Get-ApplicationsForPackage) | ForEach-Object {
                $applicationName = $_.ApplicationName
                if ($_.IncludeInPackage -and (Test-Path "$appsToPackage/$applicationName")) {
                    Write-Host "Copying $applicationName to package" -ForegroundColor Magenta
                    Copy-Item -Path "$appsToPackage/$applicationName" -Destination "$OutputPackageFolder/Apps" -Recurse -Force
                }
            }
        } else {
            throw "No apps found in: $appsToPackage" 
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
#>
function Test-PackageFolder
(
    [Parameter(Mandatory=$true)]
    $OutputPackageFolder
) 
{
    $appsInPackageFolder = Get-ChildItem -Path "$OutputPackageFolder/Apps"
    $expectedApplications = Get-ApplicationsForPackage | Where-Object IncludeInPackage

    if($appsInPackageFolder.Count -eq 0) {
        throw "No apps found in $OutputPackageFolder"
    } 

    if ($appsInPackageFolder.Count -ne $expectedApplications.Count) {
        Write-Host "Expected $($expectedApplications.Count) apps, found $($appsInPackageFolder.Count)"
    }

    $expectedApplications | ForEach-Object {
        $applicationName = $_.ApplicationName
        if (Test-Path -Path "$OutputPackageFolder/Apps/$applicationName") {
            throw "App $applicationName not found in $OutputPackageFolder"
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
