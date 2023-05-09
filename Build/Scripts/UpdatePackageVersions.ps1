Param(
    [Parameter(Mandatory = $true)]
    [string]$TargetBranch,
    [Parameter(Mandatory = $true)]
    [string]$Actor
)

# BC Container Helper is needed to fetch the latest version of one of the packages
Install-Module -Name BcContainerHelper -Force
Import-Module BcContainerHelper

Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1
Import-Module $PSScriptRoot\GuardingV2ExtensionsHelper.psm1
Import-Module $PSScriptRoot\AutomatedSubmission.psm1

$packageConfig = Get-Content -Path (Join-Path (Get-BaseFolder) "Build\Packages.json") -Raw | ConvertFrom-Json
$packageNames = ($packageConfig | Get-Member -MemberType NoteProperty).Name

$updatesAvailable = $false

foreach($packageName in $packageNames)
{
    $currentPackage = Get-ConfigValue -Key $packageName -ConfigType Packages
    $currentVersion = $currentPackage.Version
    $latestVersion = Get-PackageLatestVersion -PackageName $packageName

    if ([System.Version] $latestVersion -gt [System.Version] $currentVersion) {
        Write-Host "Updating $packageName version from $currentVersion to $latestVersion"

        $currentPackage.Version = $latestVersion

        Set-ConfigValue -Key $packageName -Value $currentPackage -ConfigType Packages

        $updatesAvailable = $true
    } else {
        Write-Host "$packageName is already up to date. Version: $currentVersion"
    }
}

if ($updatesAvailable) {
    # Create branch and push changes
    Set-GitConfig -Actor $Actor
    $BranchName = New-TopicBranch -Category "UpdatePackageVersions"
    $title = "Update package versions"
    Push-GitBranch -BranchName $BranchName -Files @("Build/Packages.json") -CommitMessage $title

    # Create PR
    $availableLabels = gh label list --json name | ConvertFrom-Json
    if ("automation" -in $availableLabels.name) {
        gh pr create --fill --head $BranchName --base $TargetBranch --label "automation"
    } else {
        gh pr create --fill --head $BranchName --base $TargetBranch
    }
    gh pr merge --auto --squash --delete-branch
} else {
    Write-Host "No updates available"
}
