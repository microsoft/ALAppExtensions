<#
.Synopsis
    Set the git config for the current actor
.Parameter Actor
    The actor to set the git config for
.Parameter Token
    The token to use for the git config
#>
function Set-GitConfig
(
    [Parameter(Mandatory=$true)]
    [string] $Actor,
    [Parameter(Mandatory=$true)]
    [string] $Token
)
{
    invoke-git config --global user.name $Actor
    invoke-git config --global user.email "$($Actor)@users.noreply.github.com"
    invoke-git config --global hub.protocol https
    invoke-git config --global core.autocrlf false
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
function Push-AutoSubmissionChange
(
    [Parameter(Mandatory=$true)]
    [string] $BranchName,
    [string[]] $Files,
    [string] $CommitMessage
) 
{
    invoke-git add $Files
    invoke-git commit -m $commitMessage
    invoke-git push -u origin $BranchName
}

<#
.Synopsis
    Creates a new branch for an automated submission
    If a subfolder is specified, the branch name will be in the format private/<subfolder>/<baselineVersion>-<currentDate>
    If a branch name is specified, the branch name will be used as is
.Parameter BranchName
    The name of the branch to create
.Parameter SubFolder
    The subfolder to use in the branch name
#>
function New-AutoSubmissionTopicBranch
{
    param
    (
        [Parameter(Mandatory=$true, ParameterSetName = 'BranchName')]
        [string] $BranchName,
        [Parameter(Mandatory=$true, ParameterSetName = 'SubFolder')]
        [string] $SubFolder
    )

    if($PsCmdlet.ParameterSetName -eq "SubFolder") {
        $currentDate = (Get-Date).ToUniversalTime().ToString("yyMMddHHmm")
        $BranchName = "private/$SubFolder/$latestBaseline-$currentDate"
    }
    
    invoke-git checkout -b $BranchName | Out-Null

    return $BranchName
}

<#
.Synopsis 
    Creates a new GitHub pull request
.Parameter Owner
    The owner of the repository
.Parameter Repo
    The name of the repository
.Parameter Title
    The title of the pull request
.Parameter Body
    The body of the pull request
.Parameter Head
    The branch to merge into the base branch
.Parameter Base
    The branch to merge into
.Parameter Token
    The token to use for the pull request
#>
function New-GitHubPullRequest {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Title,
        [string]$Body,
        [string]$Head,
        [string]$Base,
        [string]$Token
    )

    $uri = "https://api.github.com/repos/$Owner/$Repo/pulls"
    $headers = @{
        "Authorization" = "token $Token"
        "Content-Type"  = "application/json"
    }

    $body = @{
        "title" = $Title
        "body"  = $Body
        "head"  = $Head
        "base"  = $Base
    } | ConvertTo-Json

    Write-Host "Uri: $uri"
    Write-Host "Body $body"

    Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $body
}

Export-ModuleMember -Function *-*