Param(
    [Hashtable]$parameters
)

if ("$env:GITHUB_RUN_ID" -eq "") {
    $script = Join-Path $PSScriptRoot "../../../scripts/NewBcContainer.ps1" -Resolve
    . $script -parameters $parameters
}