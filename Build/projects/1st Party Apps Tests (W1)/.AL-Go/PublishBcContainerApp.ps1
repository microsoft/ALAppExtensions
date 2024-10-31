Param(
    [Hashtable]$parameters
)

$script = Join-Path $PSScriptRoot "../../../scripts/PublishBcContainerApp.ps1" -Resolve
. $script -parameters $parameters