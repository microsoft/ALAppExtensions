{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Project,
        [Parameter(Mandatory=$true)]
        $BuildMode,
        [Parameter(Mandatory=$true)]
        $Settings
    )

    Write-Host "Fetching baselines for project $Project, build mode $BuildMode, settings $Settings"
}