codeunit 4029 "W1 Company Handler"
{
    Description = 'This codeunit manages the company data transformation and loading.';
    TableNo = "Hybrid Replication Summary";

    trigger OnRun()
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
            OnUpgradePerCompanyDataForVersion(Rec, CountryCode, TargetVersion);
            OnTransformPerCompanyTableDataForVersion(CountryCode, TargetVersion);
            OnLoadTableDataForVersion(Rec, CountryCode, TargetVersion);
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnUpgradePerCompanyDataForVersion(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnTransformPerCompanyTableDataForVersion(CountryCode: Text; TargetVersion: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLoadTableDataForVersion(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
    end;
}