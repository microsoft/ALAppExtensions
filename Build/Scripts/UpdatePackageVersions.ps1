Param(
    [Parameter(Mandatory = $true)]
    [string]$TargetBranch,
    [Parameter(Mandatory = $true)]
    [string]$Actor
)

Import-Module BcContainerHelper
Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1
Import-Module $PSScriptRoot\GuardingV2ExtensionsHelper.psm1
Import-Module $PSScriptRoot\AutomatedSubmission.psm1

$packageConfig = Get-Content -Path (Join-Path (Get-BaseFolder) "Build\Packages.json") -Raw | ConvertFrom-Json
$packages = ($packageConfig | Get-Member -MemberType NoteProperty).Name

$updatesAvailable = $false

foreach($package in $packages)
{
    $currentVersion = Get-ConfigValue -Key $package -ConfigType Packages
    $latestVersion = Get-PackageLatestVersion -PackageName $package

    if ([System.Version] $latestVersion -gt [System.Version] $currentVersion) {
        Write-Host "Updating $package version from $currentVersion to $latestVersion"
        Set-ConfigValue -Key $package -Value $latestVersion -ConfigType Packages
        $updatesAvailable = $true
    } else {
        Write-Host "$package is already up to date"
    }
}

if ($updatesAvailable) {
    # Create branch and push changes
    Set-GitConfig -Actor $Actor
    $BranchName = New-TopicBranch -Category "UpdatePackagesVersions/$latestBaseline"
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