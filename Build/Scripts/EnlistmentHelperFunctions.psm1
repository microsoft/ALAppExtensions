function Get-GitBranchName() {
    if ($ENV:GITHUB_REF_NAME) {
        return $ENV:GITHUB_REF_NAME
    }
    return git rev-parse --abbrev-ref HEAD
}

function Get-BaseFolder() {
    if ($ENV:GITHUB_WORKSPACE) {
        return $ENV:GITHUB_WORKSPACE
    }
    return git rev-parse --show-toplevel
}

function Get-BuildMode() {
    if ($ENV:BuildMode) {
        return $ENV:BuildMode
    }
    return 'Default'
}