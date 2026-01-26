Param(
    [Hashtable]$parameters
)

$script = Join-Path $PSScriptRoot "../../../scripts/ImportTestDataInBcContainer.ps1" -Resolve
. $script -parameters $parameters