# Container for build metadata for a project
class ApplicationPackageMetadata
{
    [string] $ApplicationName
    [bool] $IncludeInPackage
}


function Get-ApplicationsForPackage() {
    $packageJson = "$PSScriptRoot\Package.json"
    $Packages = (Get-Content $packageJson | ConvertFrom-Json).projects
    
    $Applications = @()
    ($Packages | Get-Member -MemberType NoteProperty).Name | ForEach-Object {
        $ApplicationName = $_
    
        $ApplicationPackageMetadata = [ApplicationPackageMetadata]::new()
        $ApplicationPackageMetadata.ApplicationName = $ApplicationName
        $ApplicationPackageMetadata.IncludeInPackage = $Packages.$ApplicationName.includeInNuget
        $Applications += $ApplicationPackageMetadata
    }

    return $Applications
}

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
            $Applications = Get-ApplicationsForPackage
            $Applications | ForEach-Object {
                $ApplicationName = $_.ApplicationName
                $Include = $_.IncludeInPackage
                Write-Host "Copying $ApplicationName to package: $Include" -ForegroundColor Magenta
                #$folders = Get-ChildItem -Path $appsToPackage
                #Write-Host $folders
                if ($Include -and (Test-Path "$appsToPackage/$ApplicationName")) {
                    Copy-Item -Path "$appsToPackage/$ApplicationName" -Destination "$OutputPackageFolder/Apps" -Recurse -Force
                } else {
                    Write-Host "Skipping $ApplicationName"
                }
            }
        } else {
            throw "No apps found in: $appsToPackage" 
        }
    }

    # Copy over the license file
    Copy-Item -Path $LicensePath -Destination $OutputPackageFolder -Force
}

function Test-PackageFolder
(
    [Parameter(Mandatory=$true)]
    $OutputPackageFolder
) {
    $apps = Get-ChildItem -Path "$OutputPackageFolder/Apps"
    $expectedApplications = Get-ApplicationsForPackage

    if($apps.Count -eq 0) {
        throw "No apps found in $OutputPackageFolder"
    } 

    if ($apps.Count -ne $expectedApplications.Count) {
        Write-Host "Expected $($expectedApplications.Count) apps, found $($apps.Count)"
    }

    Write-Host $apps
    Write-Host "-----------------"
    Write-Host $expectedApplications


    $expectedApplications | ForEach-Object {
        $ApplicationName = $_.ApplicationName
        $Include = $_.IncludeInPackage
        if ($Include) {
            if(!(Test-Path -Path "$OutputPackageFolder/Apps/$ApplicationName")) {
                Write-Host "App $ApplicationName not found in $OutputPackageFolder"
            }
        }
    }
}


Export-ModuleMember *-*
