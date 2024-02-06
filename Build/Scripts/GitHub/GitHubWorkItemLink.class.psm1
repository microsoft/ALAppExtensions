
class GitHubWorkItemLink {

    <#
        Gets the linked issue IDs from the description.
        .returns
            An array of linked issue IDs.
    #>
    static [int[]] GetLinkedIssueIDs($Description) {
        if(-not $Description) {
            return @()
        }

        $workitemPattern = "(^|\s)(close|closes|closed|fix|fixes|fixed|resolve|resolves|resolved) #(?<ID>\d+)" # e.g. "Fixes #1234"
        return [GitHubWorkItemLink]::GetLinkedWorkItemIDs($workitemPattern, $Description)
    }

    <#
        Gets the linked ADO workitem IDs from the description.
        .returns
            An array of linked ADO workitem IDs.
    #>
    static [int[]] GetLinkedADOWorkItemIDs($Description) {
        if(-not $Description) {
            return @()
        }

        $workitemPattern = "AB#(?<ID>\d+)" # e.g. "AB#1234" or "Fixes AB#1234"
        return [GitHubWorkItemLink]::GetLinkedWorkItemIDs($workitemPattern, $Description)
    }

    <#
        Links the pull request to the ADO workitem.
        .returns
            The updated description.
    #>
    static [string] LinkToADOWorkItem($Description, $WorkItem) {
        if ($Description -match "AB#$($WorkItem)") {
            Write-Host "Description already links to a ADO workitem $($WorkItem)"
            return $Description
        }

        $Description += "`nFixes AB#$($WorkItem)"
        return $Description
    }

    <#
        Gets the linked workitem IDs from the description.
        .returns
            An array of linked workitem IDs.
    #>
    static [int[]] GetLinkedWorkItemIDs($Pattern, $Description) {
        if(-not $Description) {
            return @()
        }

        $workitemMatches = Select-String $Pattern -InputObject $Description -AllMatches

        if(-not $workitemMatches) {
            return @()
        }

        $workitemIds = @()
        $groups = $workitemMatches.Matches.Groups | Where-Object { $_.Name -eq "ID" }
        foreach($group in $groups) {
            $workitemIds += $group.Value
        }
        return $workitemIds
    }
}