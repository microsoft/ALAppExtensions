codeunit 4029 "W1 Company Handler"
{
    Description = 'This codeunit manages the company data transformation and loading.';
    TableNo = "Hybrid Replication Summary";

    trigger OnRun()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        TenantManagement: Codeunit "Environment Information";
        W1Management: Codeunit "W1 Management";
        CountryCode: Text;
        TargetVersion: Decimal;
        TargetVersions: List of [Decimal];
        Handled: Boolean;
    begin
        HybridCompanyStatus.Get(CompanyName);
        OnBeforeRunPerCompanyUpgrade(HybridCompanyStatus, Handled);
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
            OnUpgradePerCompanyDataForVersion(Rec, CountryCode, TargetVersion);
            OnTransformPerCompanyTableDataForVersion(CountryCode, TargetVersion);
            OnLoadTableDataForVersion(Rec, CountryCode, TargetVersion);
        end;

        Commit();
        HybridCompanyStatus.Get(CompanyName);
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Completed;
        HybridCompanyStatus.Modify();

        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        if HybridCompanyStatus.FindFirst() then begin
            W1Management.InvokePerCompanyUpgrade(Rec, HybridCompanyStatus.Name);
            exit;
        end;

        if Rec.Find() then begin
            Rec.Status := Rec.Status::Completed;
            Rec.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunPerCompanyUpgrade(var HybridCompanyStatus: Record "Hybrid Company Status"; var Handled: Boolean)
    begin
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

    var
        WrongUpgradeStatusForDataPerCompanyErr: Label 'Wrong upgrade status for Data Per company. Expected Pending, actual %1.', Comment = '%1 Upgrade status, values can be Pending, Started, Completed, Failed.';

}