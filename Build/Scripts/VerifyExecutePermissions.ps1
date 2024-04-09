param(
    [Parameter(Mandatory = $true)]
    [string] $AppFolder
)

Set-StrictMode -Version Latest
Write-Host "Verifying execute permissions on all objects in $AppFolder"

$includefilter = @('*.Table.al', '*.Report.al', '*.Codeunit.al', '*.Page.al', '*.XMlPort.al', '*.Query.al')
$AlObjects = @{}

foreach ($file in (Get-ChildItem -Path $AppFolder -Recurse -File -Filter *.al -Include $includefilter)) {
    $type = $file.BaseName.Split('.', 2)[1]
    $content = (Get-Content -Path $file.FullName) | Where-Object -FilterScript { $_ -notmatch '^\s*//' } # filter out comment lines
    $ObjectName = ($content -match "^$($type)\s\d*\s").Split(" ", 3)[2]
    if ($ObjectName.Contains(' implements ')) {
        $ObjectName = $ObjectName.Substring(0, $ObjectName.IndexOf(' implements '))
    }
    $ObjectName = $ObjectName.Trim('"')

    # check if object has ObsoleteState = Removed
    $ObsoleteRemoved = ($content -match '^\s+ObsoleteState = Removed;')
    $ObsoletePending = ($content -match '^\s+ObsoleteState = Pending;') # needed to get around #if CLEANxx

    # check if obsolete is at object level
    if ($ObsoleteRemoved) {
        $brackets = ($content -match '^\s*\{')
        if ($brackets.count -gt 1) {
            $ObsoleteRemoved = $content.IndexOf($ObsoleteRemoved[0]) -lt $content.IndexOf($brackets[1])
            if ($ObsoletePending) {
                $ObsoletePending = $content.IndexOf($ObsoletePending[0]) -lt $content.IndexOf($brackets[1])
            }
        }
        $ObsoleteRemoved = $ObsoleteRemoved -and (-not $ObsoletePending)
    }

    # check if inherent execute entitlements exist on object level
    $InherentDefined = ($content -match '(\s)InherentEntitlements.+X')

    if (!($ObsoleteRemoved) -and !($InherentDefined)) {

        if ($AlObjects.ContainsKey($type)) {
            [System.Collections.ArrayList] $AlObjects.$type += , $ObjectName
        }
        else {
            $AlObjects += @{$type = [System.Collections.ArrayList] (, $Objectname) }
        }
    }
}

# find all permissions (= X)
$includePermissionsets = @('*.permissionset.al')
foreach ($file in (Get-ChildItem -Path $AppFolder -Recurse -File -Filter *.al -Include $includePermissionsets)) {
    $content = Get-Content -Path $file.FullName
    $permissions = $content -match " = X"

    foreach ($permission in $permissions) {
        if ($permission.Contains(' Permissions = ')) {
            $permission = $permission.Substring($permission.IndexOf(' Permissions = ') + ' Permissions = '.Length)
        }

        $permission = $permission.TrimStart()

        $type = $permission.Split(' ', 2)[0]
        $ObjectName = $permission.split('=', 2)[0].Split(' ', 2)[1].Trim()
        $ObjectName = $ObjectName.Trim('"')

        # check off permissions
        if ($AlObjects.ContainsKey($type)) {
            if ($AlObjects.$type.Contains($ObjectName)) {
                # remove
                $AlObjects.$type.Remove($ObjectName)
                if ($AlObjects.$type.Count -eq 0) {
                    $AlObjects.Remove($type)
                }
            }
        }
    }
}

if ($AlObjects -and $AlObjects.Count -ne 0) {
    Write-Error "::Error:: Missing execute permissions for: `n$($AlObjects.GetEnumerator() | ForEach-Object {
        foreach($v in $_.Value) {
            "$($_.Key) $($v)`n"
        }
    })"
}