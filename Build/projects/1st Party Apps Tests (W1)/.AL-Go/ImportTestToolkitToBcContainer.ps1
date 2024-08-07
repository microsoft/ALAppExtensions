[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'parameters', Justification = 'The parameter is not used, but it''s script needs to match this format')]
Param(
    [hashtable] $parameters
)

Import-TestToolkitToBcContainer @parameters

$installAdditionalApps = (Invoke-ScriptInBCContainer -containerName $containerName -scriptblock { Get-ChildItem -Path "C:\Applications\" -Include "Microsoft_Tests-CRM integration.app" -Recurse })

foreach ($installApps in $installAdditionalApps) {
    Publish-BcContainerApp -containerName $containerName -appFile ":$($installApps.FullName)" -skipVerification -install -sync
}