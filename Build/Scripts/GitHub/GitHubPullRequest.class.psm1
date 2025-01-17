using module .\GitHubAPI.class.psm1
using module .\GitHubIssue.class.psm1
using module .\GitHubWorkItemLink.class.psm1

<#
    Class that represents a GitHub pull request.
#>
class GitHubPullRequest {
    [int] $PRNumber
    [string] $Repository
    $PullRequest

    hidden GitHubPullRequest([int] $PRNumber, [string] $Repository) {
        $this.PRNumber = $PRNumber
        $this.Repository = $Repository

        $pr = gh api "/repos/$Repository/pulls/$PRNumber" -H ([GitHubAPI]::AcceptJsonHeader) -H ([GitHubAPI]::GitHubAPIHeader) | ConvertFrom-Json
        if ($pr.message) {
            # message property is populated when the PR is not found
            Write-Host "::Warning:: Could not get PR $PRNumber from repository $Repository. Error: $($pr.message)"
            $this.PullRequest = $null
            return
        }

        $this.PullRequest = $pr
    }

    <#
        Gets the pull request from GitHub.
    #>
    static [GitHubPullRequest] Get([int] $PRNumber, [string] $Repository) {
        $pr = [GitHubPullRequest]::new($PRNumber, $Repository)

        if (-not $pr.PullRequest) {
            return $null
        }

        return $pr
    }

    static [GitHubPullRequest] GetFromBranch([string] $BranchName, [string] $Repository) {
        $openPullRequests = gh api "/repos/$Repository/pulls" --method GET -f state=open | ConvertFrom-Json
        $existingPullRequest = $openPullRequests | Where-Object { $_.head.ref -eq $BranchName } | Select-Object -First 1

        if ($existingPullRequest) {
            $pr = [GitHubPullRequest]::Get($existingPullRequest.number, $Repository)
            return $pr
        }

        return $null
    }

    <#
        Updates the pull request description.
    #>
    UpdateDescription() {
        $TempFile = New-TemporaryFile
        Set-Content -Path $TempFile -Value $this.PullRequest.body

        $params = @(
            "--body-file '$($TempFile)'" # body is the description
        )

        $parameters = ($params -join " ")
        Invoke-Expression "gh pr edit $($this.PRNumber) $parameters"

        Remove-Item $TempFile
    }

    <#
        Gets the linked issues IDs from the pull request description.
        .returns
            An array of linked issue IDs.
    #>
    [int[]] GetLinkedIssueIDs() {
        return [GitHubWorkItemLink]::GetLinkedIssueIDs($this.PullRequest.body)
    }

    <#
        Gets the linked ADO workitem IDs from the pull request description.
        .returns
            An array of linked issue IDs.
    #>
    [int[]] GetLinkedADOWorkItemIDs() {
        return [GitHubWorkItemLink]::GetLinkedADOWorkItemIDs($this.PullRequest.body)
    }

    <#
        Links the pull request to the ADO workitem.
    #>
    LinkToADOWorkItem($WorkItem) {
        $this.PullRequest.body = [GitHubWorkItemLink]::LinkToADOWorkItem($this.PullRequest.body, $WorkItem)
    }

    <#
        Returns true if the pull request is from a fork.
    #>
    [bool] IsFromFork() {
        return $this.PullRequest.head.repo.fork
    }

    <#
        Removes a comment from the pull request if it exists.
    #>
    RemoveComment($Message) {
        $existingComments = gh api "/repos/$($this.Repository)/issues/$($this.PRNumber)/comments" -H ([GitHubAPI]::AcceptJsonHeader) -H ([GitHubAPI]::GitHubAPIHeader) | ConvertFrom-Json
        $comment = $existingComments | Where-Object { $_.body -eq $Message }

        if ($comment) {
            $CommentId = $comment.id
            gh api "/repos/$($this.Repository)/issues/comments/$CommentId" -H ([GitHubAPI]::AcceptJsonHeader) -H ([GitHubAPI]::GitHubAPIHeader) -X DELETE
        }
    }

    <#
        Adds a comment to the pull request if it does not exist.
        Returns the comment object if it was added, otherwise returns null.
    #>
    [object] AddComment($Message) {
        $existingComments = gh api "/repos/$($this.Repository)/issues/$($this.PRNumber)/comments" -H ([GitHubAPI]::AcceptJsonHeader) -H ([GitHubAPI]::GitHubAPIHeader) | ConvertFrom-Json

        $commentExists = $existingComments | Where-Object { $_.body -eq $Message }
        if ($commentExists) {
            Write-Host "Comment already exists on pull request $($commentExists.html_url)"
            return $null
        }

        $comment = gh api "/repos/$($this.Repository)/issues/$($this.PRNumber)/comments" -H ([GitHubAPI]::AcceptJsonHeader) -H ([GitHubAPI]::GitHubAPIHeader) -f body="$Message" | ConvertFrom-Json
        return $comment
    }

    <#
        Adds a milestone to the pull request.
    #>
    SetMilestone($Milestone) {
        $allMilestones = gh api "/repos/$($this.Repository)/milestones" --method GET -H ([GitHubAPI]::AcceptJsonHeader) -H ([GitHubAPI]::GitHubAPIHeader) | ConvertFrom-Json
        $githubMilestone = $allMilestones | Where-Object { $_.title -eq $Milestone }
        if (-not $githubMilestone) {
            Write-Host "::Warning:: Milestone '$Milestone' not found"
            return
        }
        $milestoneNumber = $githubMilestone.number
        gh api "/repos/$($this.Repository)/issues/$($this.PRNumber)" -H ([GitHubAPI]::AcceptJsonHeader) -H ([GitHubAPI]::GitHubAPIHeader) -F milestone=$milestoneNumber | ConvertFrom-Json
    }
}
