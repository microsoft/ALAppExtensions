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

$packageParameters.appFiles = @(Get-Item -Path (Join-Path $appsFolder "*.app") | ForEach-Object { $_.FullName })
if ($testAppsFolder) {
    $packageParameters.testAppFiles = @(Get-Item -Path (Join-Path $testAppsFolder "*.app") | ForEach-Object { $_.FullName })
}
if ($dependenciesFolder.Count -gt 0) {
    $packageParameters.dependencyAppFiles = @(Get-Item -Path (Join-Path $dependenciesFolder "*.app") | ForEach-Object { $_.FullName })
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
$packageParameters.packageVersion = [System.Version] $appsFolder.SubString($appsFolder.IndexOf("-Apps-") + 6)

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

# TODO -remove
$packageParameters.packageId = 'Microsoft-ALAppExtensions-preview'
$packageParameters.packageTitle = $packageParameters.packageId

$packagePath = New-BcNuGetPackage @packageParameters

$package = Get-Item -Path $packagePath
$packageName = $package.Name

Rename-Item -Path $package.FullName -NewName "$($package.Name).zip" -Force

# Add source code to the package
$tmpFolder = Join-Path $ENV:TEMP ([GUID]::NewGuid().ToString())
Expand-Archive -Path "$($package.FullName).zip" -DestinationPath $tmpFolder

Copy-Item -Path (Join-Path . $project) -Destination (Join-Path $tmpFolder $projectName) -Recurse -Force

Compress-Archive -Path "$tmpFolder\*" -DestinationPath "$($package.FullName).zip" -Force

Remove-Item -Path $tmpFolder -Recurse -Force -ErrorAction SilentlyContinue

Rename-Item -Path "$($package.FullName).zip" -NewName $packageName -Force

Write-Host $package.FullName

#Push-BcNuGetPackage -nuGetServerUrl $nuGetServerUrl -nuGetToken $nuGetToken -bcNuGetPackage $package

#>

