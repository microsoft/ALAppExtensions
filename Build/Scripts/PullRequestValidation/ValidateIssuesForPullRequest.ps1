using module ..\GitHub\GitHubPullRequest.class.psm1
using module ..\GitHub\GitHubIssue.class.psm1

param(
    [Parameter(Mandatory = $true)]
    [string] $PullRequestNumber,
    [Parameter(Mandatory = $true)]
    [string] $Repository
)

# Set error action
$ErrorActionPreference = "Stop"

<#
    .SYNOPSIS
    Validates that the pull request description contains a line that links the pull request to an issue or workitem.
    .Description
    Validates that the pull request description contains a line that links the pull request to an issue or workitem.
    If the pull request is from a fork it must link to an issue.
    If the pull request is not from a fork it must link to an issue or an ADO workitem.
#>
function Test-WorkitemIsLinked() {
    param(
        [Parameter(Mandatory = $false)]
        [string[]] $IssueIds,
        [Parameter(Mandatory = $false)]
        [string[]] $ADOWorkItems,
        [Parameter(Mandatory = $false)]
        [object] $PullRequest
    )

    $Comment = "Could not find linked issues in the pull request description. Please make sure the pull request description contains a line that contains 'Fixes #' followed by the issue number being fixed. Use that pattern for every issue you want to link."

    if (-not $PullRequest.IsFromFork()) {
        $Comment += " You can also link ADO workitems by using the pattern 'Fixes AB#' followed by the workitem number being fixed."
    }

    if (-not $IssueIds) {
        # If the pull request is from a fork, add a comment to the pull request and throw an error
        # If the pull request is not from a fork only throw an error if there are no linked ADO workitems
        if ($PullRequest.IsFromFork() -or (-not $ADOWorkItems)) {
            $PullRequest.AddComment($Comment)
            throw $Comment
        }
    }
    $PullRequest.RemoveComment($Comment)
}

<#
    .SYNOPSIS
    Validates all issues linked to a pull request.
    .Description
    Validates all issues linked to a pull request. All linked issues must be open and approved.
#>
function Test-GitHubIssue() {
    param(
        [Parameter(Mandatory = $false)]
        [string] $Repository,
        [Parameter(Mandatory = $false)]
        [string[]] $IssueIds,
        [Parameter(Mandatory = $false)]
        [object] $PullRequest
    )
    $invalidIssues = @()

    foreach ($issueId in $IssueIds) {
        Write-Host "Validating issue $issueId"
        $issue = [GitHubIssue]::Get($issueId, $Repository)

        # If the issue is not approved, add a comment to the pull request and throw an error
        $isValid = $issue -and ((-not $PullRequest.IsFromFork()) -or $issue.IsApproved()) -and $issue.IsOpen() -and (-not $issue.IsPullRequest())
        $Comment = "Issue #$($issueId) is not valid. Please make sure you link an **issue** that exists, is **open** and is **approved**."
        if (-not $isValid) {
            $PullRequest.AddComment($Comment)
            $invalidIssues += $issueId
        }
        else {
            $PullRequest.RemoveComment($Comment)
        }
    }

    if($invalidIssues) {
        throw "The following issues are not open or approved: $($invalidIssues -join ', ')"
    }
}

Write-Host "Validating PR $PullRequestNumber"

$pullRequest = [GitHubPullRequest]::Get($PullRequestNumber, $Repository)
$issueIds = $pullRequest.GetLinkedIssueIDs()
$adoWorkitems = $pullRequest.GetLinkedADOWorkitems()

Test-WorkitemIsLinked -IssueIds $issueIds -ADOWorkItems $adoWorkitems -PullRequest $PullRequest
Test-GitHubIssue -Repository $Repository -IssueIds $issueIds -PullRequest $PullRequest

Write-Host "PR $PullRequestNumber validated successfully" -ForegroundColor Green