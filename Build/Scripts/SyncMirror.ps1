param(
    [Parameter(Mandatory=$true)]
    [string] $SourceRepository,
    [Parameter(Mandatory=$true)]
    [string] $TargetRepository,
    [Parameter(Mandatory=$false)]
    [string] $Branch,
    [Parameter(Mandatory=$false)]
    [switch] $ManagedIdentityAuth
)

Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1

function Get-AccessToken {
    param(
        [switch] $ManagedIdentityAuth
    )

    if ($ManagedIdentityAuth) {
        az login --identity --allow-no-subscriptions | Out-Null
    } else {
        az login
    }
    return (az account get-access-token | ConvertFrom-Json)
}

$MIAccessToken = Get-AccessToken -ManagedIdentityAuth:$ManagedIdentityAuth

git clone "https://$($MIAccessToken.accessToken)@$TargetRepository" BCApps
Push-Location BCApps

# Fetch repos
RunAndCheck git reset HEAD --hard
RunAndCheck git remote add upstream $SourceRepository
RunAndCheck git fetch --all

# If a branch is provided, sync the branch with the target repository
if ($Branch) {
    $Branch = $Branch -replace "refs/heads/", ""
    if (RunAndCheck git ls-remote origin $Branch) {
        # If branch exists in target, checkout branch and pull changes from target repository
        Write-Host "Checking out $Branch from $TargetRepository"
        if ($Branch -ne "main") {
            RunAndCheck git checkout origin/$Branch --track
        }
        RunAndCheck git pull origin $Branch
    }
    else {
        # Checkout branch directly from upstream
        Write-Host "Checking out $Branch from $SourceRepository"
        RunAndCheck git checkout upstream/$Branch --track
    }

    # Merge changes from upstream
    RunAndCheck git pull upstream $Branch

    # Push to origin
    Write-Host "Pushing $Branch to $TargetRepository"
    RunAndCheck git push origin $Branch
}

# Push tags to the target
Write-Host "Pushing tags to $TargetRepository"
RunAndCheck git push origin --tags

Pop-Location