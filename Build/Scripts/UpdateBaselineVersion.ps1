Param(
    [Parameter(Mandatory = $true)]
    [string]$TargetBranch,
    [Parameter(Mandatory = $true)]
    [string]$Actor
)

Install-Module -Name BcContainerHelper -Force

Import-Module BcContainerHelper
Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1
Import-Module $PSScriptRoot\GuardingV2ExtensionsHelper.psm1
Import-Module $PSScriptRoot\AutomatedSubmission.psm1

$latestBaseline = Get-LatestBaselineVersionFromArtifacts
$currentBaseline = Get-ConfigValue -Key "baselineVersion" -ConfigType "BuildConfig" 

if ([System.Version] $latestBaseline -gt [System.Version] $currentBaseline) {
    Write-Host "Updating baseline version from $currentBaseline to $latestBaseline"
    Set-ConfigValue -Key "baselineVersion" -Value $latestBaseline -ConfigType "BuildConfig"

    # Create branch and push changes
    Set-GitConfig -Actor $Actor
    $BranchName = New-TopicBranch -Category "UpdateBaselineVersion/$latestBaseline"
    $title = "Update baseline version to $latestBaseline"
    Push-GitBranch -BranchName $BranchName -Files @("Build/BuildConfig.json") -CommitMessage $title

    # Create PR
    $availableLabels = gh label list --json name | ConvertFrom-Json
    if ("automation" -in $availableLabels.name) {
        gh pr create --fill --head $BranchName --base $TargetBranch --label "automation"
    } else {
        gh pr create --fill --head $BranchName --base $TargetBranch
    }
    gh pr merge --auto --squash --delete-branch
} else {
    Write-Host "Current baseline version is already up to date"
}