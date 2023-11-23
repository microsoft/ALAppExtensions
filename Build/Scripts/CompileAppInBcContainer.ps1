Param(
    [Hashtable] $parameters
)

# $app, $testApp and $bcptTestApp are boolean variables to determine the app type
$appType = switch ($true) {
    $app { "app" }
    $testApp { "testApp" }
    $bcptTestApp { "bcptApp" }
    Default { "app" }
}

$PreCompileApp = (Get-Command "$PSScriptRoot\PreCompileApp.ps1" | Select-Object -ExpandProperty ScriptBlock)
Invoke-Command -ScriptBlock $PreCompileApp -ArgumentList $appType, ([ref] $parameters)

$appFile = Compile-AppInBcContainer @parameters

# Return the app file path
$appFile