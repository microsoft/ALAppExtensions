using module ..\GitHub\GitHubPullRequest.class.psm1

param(
    [Parameter(Mandatory = $true)]
    [string] $PullRequestNumber,
    [Parameter(Mandatory = $true)]
    [string] $Repository
)
Import-Module $PSScriptRoot\..\EnlistmentHelperFunctions.psm1

$pullRequest = [GitHubPullRequest]::Get($PullRequestNumber, $Repository)

if (-not $pullRequest) {
    throw "Could not get PR $PullRequestNumber from repository $Repository"
}

if ($pullRequest.PullRequest.labels -contains "automation") {
    return # Don't set milestone on automation PRs
}

# Get milestone
$repoVersion = Get-ConfigValue -Key "repoVersion" -ConfigType AL-GO
$milestone = "Version $repoVersion"

Write-Host "Setting milestone '$milestone' on PR $PullRequestNumber"
$pullRequest.SetMilestone($milestone)