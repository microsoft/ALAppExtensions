codeunit 4055 "Execute Non-Company Upgrade"
{
    Description = 'This codeunit executes Non-Company upgrade.';
    TableNo = "Hybrid Replication Summary";
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        TryExecuteNonCompanyUpgrade(Rec);
    end;

    local procedure TryExecuteNonCompanyUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        TenantManagement: Codeunit "Environment Information";
        W1Management: Codeunit "W1 Management";
        CountryCode: Text;
        TargetVersion: Decimal;
        TargetVersions: List of [Decimal];
    begin
        CountryCode := TenantManagement.GetApplicationFamily();
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        foreach TargetVersion in TargetVersions do begin
            // Perform the straight upgrade for "unstaged" tables.
            W1Management.OnUpgradeNonCompanyDataForVersion(HybridReplicationSummary, TargetVersion);

            // Perform the transform and load actions for tables that went to a "staging" table.
            W1Management.OnTransformNonCompanyTableDataForVersion(CountryCode, TargetVersion);
            W1Management.OnLoadNonCompanyTableDataForVersion(HybridReplicationSummary, CountryCode, TargetVersion);
        end;
    end;
}