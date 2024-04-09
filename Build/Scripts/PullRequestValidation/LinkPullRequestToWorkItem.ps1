using module ..\GitHub\GitHubPullRequest.class.psm1
using module ..\GitHub\GitHubIssue.class.psm1

param(
    [Parameter(Mandatory = $true)]
    [string] $PullRequestNumber,
    [Parameter(Mandatory = $true)]
    [string] $Repository
)

function Update-GitHubPullRequest() {
    param(
        [Parameter(Mandatory = $false)]
        [object] $PullRequest,
        [Parameter(Mandatory = $false)]
        [string[]] $IssueIds
    )

    # Find all ADO work items linked to the provided issues and link them to the PR
    foreach ($issueId in $IssueIds) {
        Write-Host "Trying to link work items from $issueId to pull request $($PullRequest.PRNumber)"

        $issue = [GitHubIssue]::Get($issueId, $PullRequest.Repository)
        if (-not $issue) {
            Write-Host "Issue $issueId not found in repository $($PullRequest.Repository)"
            continue
        }

        $adoWorkItems = $issue.GetLinkedADOWorkItemIDs()
        if (-not $adoWorkItems) {
            Write-Host "No ADO workitems found in issue $issueId"
            continue
        }

        foreach ($adoWorkItem in $adoWorkItems) {
            $PullRequest.LinkToADOWorkItem($adoWorkItem)
        }
    }

    # Update the pull request description
    $PullRequest.UpdateDescription()
}

$pullRequest = [GitHubPullRequest]::Get($PullRequestNumber, $Repository)
if (-not $pullRequest) {
    throw "Could not get PR $PullRequestNumber from repository $Repository"
}

$issueIds = $pullRequest.GetLinkedIssueIDs()

Write-Host "Updating pull request $PullRequestNumber with linked issues $issueIds"
Update-GitHubPullRequest -PullRequest $PullRequest -IssueIds $issueIds