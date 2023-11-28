<#
.SYNOPSIS
    Updates the package versions in the Packages.json file to the latest version available on the corresponding source.
.DESCRIPTION
    This script will update the package versions in the Packages.json file to the latest version available on the corresponding source.
    If the version is updated, a new branch will be created and a pull request will be created to merge the changes into the target branch.
.PARAMETER TargetBranch
    The branch to create the pull request to
.PARAMETER Actor
    The name of the user that will be used as commit author
#>
Param(
    [Parameter(Mandatory = $true)]
    [string]$Repository,
    [Parameter(Mandatory = $true)]
    [string]$TargetBranch,
    [Parameter(Mandatory = $true)]
    [string]$Actor
)

# BC Container Helper is needed to fetch the latest version of one of the packages
Install-Module -Name BcContainerHelper -AllowPrerelease -Force
Import-Module BcContainerHelper

Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1
Import-Module $PSScriptRoot\GuardingV2ExtensionsHelper.psm1
Import-Module $PSScriptRoot\AutomatedSubmission.psm1

function UpdatePackageVersions() {
    $packageConfig = Get-Content -Path (Join-Path (Get-BaseFolder) "build\Packages.json") -Raw | ConvertFrom-Json
    $packageNames = ($packageConfig | Get-Member -MemberType NoteProperty).Name

    $updatesAvailable = $false

    foreach($packageName in $packageNames)
    {
        $currentPackage = Get-ConfigValue -Key $packageName -ConfigType Packages
        $currentVersion = $currentPackage.Version

        if ($currentPackage.PSobject.Properties.name -eq "MaxVersion") {
            $latestVersion = Get-PackageLatestVersion -PackageName $packageName -MaxVersion $currentPackage.MaxVersion
        } else {
            $latestVersion = Get-PackageLatestVersion -PackageName $packageName
        }

        if ([System.Version] $latestVersion -gt [System.Version] $currentVersion) {
            Write-Host "Updating $packageName version from $currentVersion to $latestVersion"

            $currentPackage.Version = $latestVersion

            Set-ConfigValue -Key $packageName -Value $currentPackage -ConfigType Packages

            $updatesAvailable = $true
        } else {
            Write-Host "$packageName is already up to date. Version: $currentVersion"
        }
    }

    return $updatesAvailable
}

$pullRequestTitle = "[$TargetBranch] Update package versions"
$BranchName = New-TopicBranchIfNeeded -Repository $Repository -Category "UpdatePackageVersions/$TargetBranch" -PullRequestTitle $pullRequestTitle

$updatesAvailable = UpdatePackageVersions

if ($updatesAvailable) {
    # Create branch and push changes
    Set-GitConfig -Actor $Actor
    Push-GitBranch -BranchName $BranchName -Files @("build/Packages.json") -CommitMessage $pullRequestTitle
    New-GitHubPullRequest -Repository $Repository -BranchName $BranchName -TargetBranch $TargetBranch -label "automation"
} else {
    Write-Host "No updates available"
}
