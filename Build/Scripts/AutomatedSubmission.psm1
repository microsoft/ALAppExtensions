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

Export-ModuleMember -Function *-*