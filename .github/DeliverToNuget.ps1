Param(
    [Hashtable] $parameters
)

try {
    $nuGetAccount = $parameters.Context | ConvertFrom-Json | ConvertTo-HashTable
    $nuGetServerUrl = $nuGetAccount.ServerUrl
    $nuGetToken = $nuGetAccount.Token
    Write-Host "NuGetContext OK"
}
catch {
    throw "NuGetContext secret is malformed. Needs to be formatted as Json, containing serverUrl and token as a minimum."
}

$project = $parameters.project
$projectName = $parameters.projectName
$appsFolder = $parameters.appsFolder
$testAppsFolder = $parameters.testAppsFolder
$type = $parameters.type

$packageParameters = @{
    "gitHubRepository" = "$ENV:GITHUB_SERVER_URL/$ENV:GITHUB_REPOSITORY"
}

# Determine package ID
if ($nuGetAccount.ContainsKey('PackageName')) {
    $packageParameters.packageId = $nuGetAccount.PackageName.replace('{project}', $projectName).replace('{owner}', $ENV:GITHUB_REPOSITORY_OWNER).replace('{repo}',$env:RepoName)
}
else {
    if ($project -and ($project -eq '.')) {
        $packageParameters.packageId = "$($ENV:GITHUB_REPOSITORY_OWNER)-$($env:RepoName)"
    }
    else {
        $packageParameters.packageId = "$($ENV:GITHUB_REPOSITORY_OWNER)-$($env:RepoName)-$projectName"
    }
}

if ($type -eq 'CD') {
    $packageParameters.packageId += "-preview"
}

# Determine package version
$packageParameters.packageVersion = $appsFolder.SubString($appsFolder.IndexOf("-Apps-") + 6)

# Determine package title
if ($nuGetAccount.ContainsKey('PackageTitle')) {
    $packageParameters.packageTitle = $nuGetAccount.PackageTitle
}
else {
     $packageParameters.packageTitle = $packageParameters.packageId
}

# Determine package description
if ($nuGetAccount.ContainsKey('PackageDescription')) {
    $packageParameters.packageDescription = $nuGetAccount.PackageDescription
}
else {
    $packageParameters.packageDescription = $packageParameters.packageTitle
}

# Determine package authors
if ($nuGetAccount.ContainsKey('PackageAuthors')) {
    $packageParameters.packageAuthors = $nuGetAccount.PackageAuthors
}
else {
    $packageParameters.packageAuthors = 'mazhelez'
}

Write-Host "Package parameters: "
$packageParameters

$nuspec = GenerateNuspecTemplate `
            -PackageId $packageParameters.packageId `
            -Version $packageParameters.packageVersion `

$packageFolder = Join-Path $env:TEMP ([GUID]::NewGuid().ToString())
New-Item -Path $packageFolder -ItemType Directory | Out-Null

Write-Host "Package folder: $packageFolder"

try {
    Write-Host "Copy main app files to package folder $packageFolder"
    (gci -Path $appsFolder -Filter "*.app") | % {
        Copy-Item -Path $_.FullName -Destination $packageFolder -Force
    
        $fileElement = $nuspec.CreateElement("file")
        $fileElement.SetAttribute("src", $_.Name)
        $fileElement.SetAttribute("target", $_.Name)
    
        $nuspec.package.files.AppendChild($fileElement) | Out-Null
    }
    
    Write-Host "Copy test app files to package folder $packageFolder"
    (gci -Path $testAppsFolder -Filter "*.app") | % {
        Copy-Item -Path $_.FullName -Destination $packageFolder -Force -Container
    
        $fileElement = $nuspec.CreateElement("file")
        $fileElement.SetAttribute("src", $_.Name)
        $fileElement.SetAttribute("target", (Join-Path 'Tests' $_.Name))
    
        $nuspec.package.files.AppendChild($fileElement) | Out-Null
    }
    
    Write-Host "Copy source code for project $project to package folder $packageFolder"
    Copy-Item -Path (Join-Path $ENV:GITHUB_WORKSPACE $project) -Destination (Join-Path $packageFolder 'SourceCode') -Recurse -Force
    $fileElement = $nuspec.CreateElement("file")
    $fileElement.SetAttribute("src", "SourceCode\**")
    $fileElement.SetAttribute("target", "SourceCode")
    
    $nuspec.package.files.AppendChild($fileElement) | Out-Null
    
    #Create .nuspec file(Join-Path $packageFolder 'manifest.nuspec')
    $nuspecFilePath = (Join-Path $packageFolder 'manifest.nuspec')
    $nuspec.Save($nuspecFilePath)
    
    # Download nuget CLI
    # Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile ./nuget.exe
    
    $nugetOutput =  Invoke-Expression -Command "./nuget.exe pack $nuspecFilePath -OutputDirectory ."
    
    $nugetOutput | Write-Host
    if ($LASTEXITCODE -or $null -eq $nugetOutput)
    {
        throw "Generating the nuget pack failed with exit code $LASTEXITCODE"
    }
    
    $nugetOutput
}
finally {
    Remove-Item $packageFolder -Recurse -Force
}

$nugetPackageFile = gci -Path '.' -Filter "$($packageParameters.packageId)*.nupkg"

if(-not $nugetPackageFile) {
    throw "Cannot find nupkg file"
}

Write-Host "Push package $($nugetPackageFile.FullName) to $nuGetServerUrl"
$nugetOutput =  Invoke-Expression -Command "./nuget.exe push $($nugetPackageFile.FullName) -ApiKey $nuGetToken -Source $nuGetServerUrl"

$nugetOutput

function GenerateNuspecTemplate
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
            <title>Dynamics SMB Business Central</title>
            <authors>Microsoft</authors>
            <owners>Microsoft</owners>
            <requireLicenseAcceptance>false</requireLicenseAcceptance>
            <description>System Application for D365 Business Central</description>
            <summary>System Application for D365 Business Central</summary>
        </metadata>
	    <files>
	    </files>
    </package>'

    $template.package.metadata.id = $PackageId
    $template.package.metadata.version = $Version
    $template.package.files.file.Attributes['src'].Value = "$PackageSrcDir"
    $template.package.files.file.Attributes['target'].Value = "$PackageTargetDirName"

    return $template
}

