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
    .Synopsis
    Validates that the pull request description contains a line that links the pull request to an ADO workitem.
    .Parameter ADOWorkItems
    The IDs of the ADO workitems linked to the pull request.
    .Parameter PullRequest
    The pull request to validate.
#>
function Test-ADOWorkItemIsLinked() {
    param(
        [Parameter(Mandatory = $false)]
        [string[]] $ADOWorkItems,
        [Parameter(Mandatory = $false)]
        [object] $PullRequest
    )

    $Comment = "Could not find a linked ADO work item. Please link one by using the pattern 'AB#' followed by the relevant work item number. You may use the 'Fixes' keyword to automatically resolve the work item when the pull request is merged. E.g. 'Fixes AB#1234'"

    if (-not $ADOWorkItems) {
        # If the pull request is not from a fork, add a comment to the pull request
        if (-not $PullRequest.IsFromFork()) {
            $PullRequest.AddComment($Comment)
        }

        # Throw an error if there is no linked ADO workitem
        throw $Comment
    }

    $PullRequest.RemoveComment($Comment)
}

Write-Host "Validating PR $PullRequestNumber"

$pullRequest = [GitHubPullRequest]::Get($PullRequestNumber, $Repository)
if (-not $pullRequest) {
    throw "Could not get PR $PullRequestNumber from repository $Repository"
}

$adoWorkItems = $pullRequest.GetLinkedADOWorkItemIDs()

# Validate that all pull requests links to an ADO workitem
Test-ADOWorkItemIsLinked -ADOWorkItems $adoWorkItems -PullRequest $PullRequest

Write-Host "PR $PullRequestNumber validated successfully" -ForegroundColor Green