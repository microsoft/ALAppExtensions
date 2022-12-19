Param(
    [Hashtable] $parameters
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

try 
{
    $deliverContext = $parameters.Context | ConvertFrom-Json | ConvertTo-HashTable
    $deliverServerUrl = $deliverContext.ServerUrl
    $deliverAcountToken = $deliverContext.Token
}
catch 
{
    throw "Deliver context is malformed. Needs to be formatted as JSON, containing serverUrl and token."
}

if (-not ($deliverServerUrl)) 
{
    throw "Cannot retrieve server URL from the deliver context"
} 

if (-not $deliverAcountToken) 
{
    throw "Cannot retrieve account token the deliver context"
} 

Write-Host "Successfully retrieved information from the deliver context" -ForegroundColor Green

Write-Host $parameters -ForegroundColor Magenta

$project = $parameters.project
$projectName = $parameters.projectName
$appsFolders = $parameters.appsFolders
$testAppsFolders = $parameters.testAppsFolders
$type = $parameters.type

Write-Host "App folder(s): $($appsFolders -join ', ')" -ForegroundColor Magenta
Write-Host "Test app folder(s): $($testAppsFolders -join ', ')" -ForegroundColor Magenta

# Construct package ID
$packageId = "$($env:GITHUB_REPOSITORY_OWNER)-$($env:RepoName)"

if (-not $project -or ($project -ne '.')) 
{
    $packageId += "-$projectName"
}

if ($type -eq 'CD') 
{
    $packageId += "-preview"
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
$packageFolder = Join-Path $env:TEMP ([GUID]::NewGuid().ToString())
New-Item -Path $packageFolder -ItemType Directory | Out-Null

Write-Host "Package folder: $packageFolder" -ForegroundColor Magenta

try 
{
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
    
    $outputDirectory = Join-Path $env:GITHUB_WORKSPACE 'out'
    New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null

    Write-Host "Download nuget CLI" -ForegroundColor Magenta
    Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile $outputDirectory/nuget.exe
    
    $deliverOutput =  Invoke-Expression -Command "$outputDirectory/nuget.exe pack $manifestFilePath -OutputDirectory $outputDirectory"
    
    $deliverOutput | Write-Host -ForegroundColor Magenta
    if ($LASTEXITCODE -or $null -eq $deliverOutput)
    {
        throw "Generating the package failed with exit code $LASTEXITCODE"
    }
    
    # Get the newly created package
    $packageFile = Get-ChildItem -Path $outputDirectory -Filter "$packageId*.nupkg"

    if(-not $packageFile) 
    {
        throw "Cannot find the package file in $outputDirectory"
    }

    Write-Host "Push package $($packageFile.FullName) to $deliverServerUrl" -ForegroundColor Magenta
    $deliverOutput =  Invoke-Expression -Command "$outputDirectory/nuget.exe push $($packageFile.FullName) -ApiKey $deliverAcountToken -Source $deliverServerUrl"

    if ($LASTEXITCODE -or $null -eq $deliverOutput)
    {
        throw "Pushing package $($packageFile.FullName) failed with exit code $LASTEXITCODE"
    }
}
finally 
{
    Remove-Item $packageFolder -Recurse -Force
}
