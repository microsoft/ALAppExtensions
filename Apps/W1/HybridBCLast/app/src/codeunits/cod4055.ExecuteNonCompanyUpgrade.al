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
        HybridCompanyStatus: Record "Hybrid Company Status";
        TenantManagement: Codeunit "Environment Information";
        W1Management: Codeunit "W1 Management";
        CountryCode: Text;
        TargetVersion: Decimal;
        TargetVersions: List of [Decimal];
        Handled: Boolean;
    begin
        HybridCompanyStatus.Get('');

        OnBeforeRunPerDatabaseUpgrade(HybridCompanyStatus, Handled);
        if Handled then
            exit;

        if HybridCompanyStatus."Upgrade Status" <> HybridCompanyStatus."Upgrade Status"::Pending then
            Error(WrongUpgradeStatusForDataPerCompanyErr, HybridCompanyStatus."Upgrade Status");

        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Started;
        HybridCompanyStatus.Modify();
        Commit();

        CountryCode := TenantManagement.GetApplicationFamily();
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        foreach TargetVersion in TargetVersions do begin
            // Perform the straight upgrade for "unstaged" tables.
            W1Management.OnUpgradeNonCompanyDataForVersion(HybridReplicationSummary, TargetVersion);

            // Perform the transform and load actions for tables that went to a "staging" table.
            W1Management.OnTransformNonCompanyTableDataForVersion(CountryCode, TargetVersion);
            W1Management.OnLoadNonCompanyTableDataForVersion(HybridReplicationSummary, CountryCode, TargetVersion);
        end;
        Commit();

        HybridCompanyStatus.Get('');
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Completed;
        HybridCompanyStatus.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunPerDatabaseUpgrade(var HybridCompanyStatus: Record "Hybrid Company Status"; var Handled: Boolean)
    begin
    end;

    var
        WrongUpgradeStatusForDataPerCompanyErr: Label 'Wrong upgrade status for Data Per company. Expected Pending, actual %1.', Comment = '%1 Upgrade status, values can be Pending, Started, Completed, Failed.';
}