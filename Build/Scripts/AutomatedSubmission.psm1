<#
.Synopsis
    Set the git config for the current actor
.Parameter Actor
    The actor to set the git config for
#>
function Set-GitConfig
(
    [Parameter(Mandatory=$true)]
    [string] $Actor
)
{
    git config --global user.name $Actor
    git config --global user.email "$($Actor)@users.noreply.github.com"
    git config --global hub.protocol https
    git config --global core.autocrlf false
}

<#
.Synopsis
    Stages files for commit and pushes them to the specified branch
.Parameter BranchName
    The name of the branch to push to
.Parameter Files
    The files to stage for commit
.Parameter CommitMessage
    The commit message to use
#>
function Push-GitBranch
(
    [Parameter(Mandatory=$true)]
    [string] $BranchName,
    [string[]] $Files,
    [string] $CommitMessage
)
{
    git add $Files
    git commit -m $commitMessage
    git push -u origin $BranchName
}

<#
.Synopsis
    Creates a new branch for an automated submission
    If a subfolder is specified, the branch name will be in the format automation/<subfolder>/<baselineVersion>-<currentDate>
    If a branch name is specified, the branch name will be used as is
.Parameter BranchName
    The name of the branch to create
.Parameter Category
    The category to use in the branch name
#>
function New-TopicBranch
{
    param
    (
        [Parameter(Mandatory=$true, ParameterSetName = 'BranchName')]
        [string] $BranchName,
        [Parameter(Mandatory=$true, ParameterSetName = 'Category')]
        [string] $Category
    )

    if($PsCmdlet.ParameterSetName -eq "Category") {
        $currentDate = (Get-Date).ToUniversalTime().ToString("yyMMddHHmm")
        $BranchName = "automation/$Category/$currentDate"
    }

    git checkout -b $BranchName | Out-Null

    return $BranchName
}

function New-TopicBranchIfNeeded
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $Repository,
        [Parameter(Mandatory=$true, ParameterSetName = 'BranchName')]
        [string] $BranchName,
        [Parameter(Mandatory=$true, ParameterSetName = 'Category')]
        [string] $Category,
        [Parameter(Mandatory=$false)]
        [string] $PullRequestTitle
    )
    $openPullRequests = gh api "/repos/$Repository/pulls" --method GET -f state=open | ConvertFrom-Json

    $openPullRequests = $openPullRequests | Where-Object { $_.head.ref -match $Category }
    if ($PullRequestTitle) {
        $openPullRequests = $openPullRequests | Where-Object { $_.title -eq $PullRequestTitle }
    }

    $existingPullRequest = $openPullRequests | Select-Object -First 1

    if ($existingPullRequest) {
        $BranchName = $existingPullRequest.head.ref
        git fetch origin $BranchName
        git checkout $BranchName | Out-Null
    } else {
        $BranchName = New-TopicBranch -Category $Category
    }

    return $BranchName
}

function New-GitHubPullRequest
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $Repository,
        [Parameter(Mandatory=$true)]
        [string] $BranchName,
        [Parameter(Mandatory=$true)]
        [string] $TargetBranch,
        [Parameter(Mandatory=$false)]
        [string] $label = "automation"
    )

    $openPullRequests = gh api "/repos/$Repository/pulls" --method GET -f state=open | ConvertFrom-Json
    $existingPullRequest = $openPullRequests | Where-Object {$_.head.ref -eq $BranchName} | Select-Object -First 1

    if ($existingPullRequest) {
        Write-Host "Pull request already exists for branch ($BranchName): $($existingPullRequest.html_url)"
        return
    }

    $availableLabels = gh label list --json name | ConvertFrom-Json
    if ($label -in $availableLabels.name) {
        gh pr create --fill --head $BranchName --base $TargetBranch --label $label
    } else {
        gh pr create --fill --head $BranchName --base $TargetBranch
    }
    gh pr merge --auto --squash --delete-branch
}

Export-ModuleMember -Function *-*