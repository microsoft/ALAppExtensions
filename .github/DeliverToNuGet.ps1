Param(
    [Hashtable] $parameters
)

function GenerateNuspec
(
    [Parameter(Mandatory=$true)]
    $PackageId,
    [Parameter(Mandatory=$true)]
    $Version
)
{
    [xml] $template = '<?xml version="1.0" encoding="utf-8"?>
    <package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
        <metadata>
            <id></id>
            <version></version>
            <title>Dynamics SMB Business Central — System Application</title>
            <authors>Microsoft</authors>
            <owners>Microsoft</owners>
            <requireLicenseAcceptance>false</requireLicenseAcceptance>
            <description>System Application for D365 Business Central</description>
            <summary>System Application for D365 Business Central</summary>
        </metadata>
	    <files>
            <file src="SourceCode\**" target="SourceCode" exclude="**\.AL-Go\**"/>
	    </files>
    </package>'

    $template.package.metadata.id = $PackageId
    $template.package.metadata.version = $Version

    return $template
}

try {
    $nuGetAccount = $parameters.Context | ConvertFrom-Json | ConvertTo-HashTable
    $nuGetServerUrl = $nuGetAccount.ServerUrl
    $nuGetToken = $nuGetAccount.Token
    Write-Host "NuGetContext OK" -ForegroundColor Magenta
}
catch {
    throw "NuGetContext secret is malformed. Needs to be formatted as Json, containing serverUrl and token as a minimum."
}

$project = $parameters.project
$projectName = $parameters.projectName
$appsFolder = $parameters.appsFolder
$testAppsFolder = $parameters.testAppsFolder
$type = $parameters.type

$packageId = "$($env:GITHUB_REPOSITORY_OWNER)-$($env:RepoName)"

if (-not $project -or ($project -ne '.')) {
    $packageId += "-$projectName"
}

if ($type -eq 'CD') {
    $packageId += "-preview"
}

# Extract version from the published folders (naming convention)
$packageVersion = $appsFolder.SubString($appsFolder.IndexOf("-Apps-") + 6)

$nuspec = GenerateNuspec `
            -PackageId $packageId `
            -Version $packageVersion `

$packageFolder = Join-Path $env:TEMP ([GUID]::NewGuid().ToString())
New-Item -Path $packageFolder -ItemType Directory | Out-Null

Write-Host "Package folder: $packageFolder" -ForegroundColor Magenta

try {
    Write-Host "Copy main app files to package folder $packageFolder" -ForegroundColor Magenta
    (gci -Path $appsFolder -Filter "*.app") | % {
        Copy-Item -Path $_.FullName -Destination $packageFolder -Force
    
        $fileElement = $nuspec.CreateElement("file")
        $fileElement.SetAttribute("src", $_.Name)
        $fileElement.SetAttribute("target", $_.Name)
    
        $nuspec.package.files.AppendChild($fileElement) | Out-Null
    }
    
    Write-Host "Copy test app files to package folder $packageFolder" -ForegroundColor Magenta
    (gci -Path $testAppsFolder -Filter "*.app") | % {
        Copy-Item -Path $_.FullName -Destination $packageFolder -Force -Container
    
        $fileElement = $nuspec.CreateElement("file")
        $fileElement.SetAttribute("src", $_.Name)
        $fileElement.SetAttribute("target", (Join-Path 'Tests' $_.Name))
    
        $nuspec.package.files.AppendChild($fileElement) | Out-Null
    }
    
    Write-Host "Copy source code for project $project to package folder $packageFolder/SourceCode" -ForegroundColor Magenta
    Copy-Item -Path (Join-Path $env:GITHUB_WORKSPACE $project) -Destination (Join-Path $packageFolder 'SourceCode') -Recurse -Force
    
    #Create .nuspec file(Join-Path $packageFolder 'manifest.nuspec')
    $nuspecFilePath = (Join-Path $packageFolder 'manifest.nuspec')
    $nuspec.Save($nuspecFilePath)
    
    $outputDirectory = Join-Path $env:GITHUB_WORKSPACE 'out'
    New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null

    Write-Host "Download nuget CLI" -ForegroundColor Magenta
    Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile $outputDirectory/nuget.exe
    
    $nugetOutput =  Invoke-Expression -Command "$outputDirectory/nuget.exe pack $nuspecFilePath -OutputDirectory $outputDirectory"
    
    $nugetOutput | Write-Host -ForegroundColor Magenta
    if ($LASTEXITCODE -or $null -eq $nugetOutput)
    {
        throw "Generating the nuget pack failed with exit code $LASTEXITCODE"
    }
}
finally {
    Remove-Item $packageFolder -Recurse -Force
}

# Get the newly created package
$nugetPackageFile = gci -Path $outputDirectory -Filter "$packageId*.nupkg"

if(-not $nugetPackageFile) {
    throw "Cannot find nupkg file"
}

Write-Host "Push package $($nugetPackageFile.FullName) to $nuGetServerUrl" -ForegroundColor Magenta
$nugetOutput =  Invoke-Expression -Command "$outputDirectory/nuget.exe push $($nugetPackageFile.FullName) -ApiKey $nuGetToken -Source $nuGetServerUrl"

if ($LASTEXITCODE -or $null -eq $nugetOutput)
{
    throw "Pushing nuget package $($nugetPackageFile.FullName) failed with exit code $LASTEXITCODE"
}

