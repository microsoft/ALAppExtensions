codeunit 11739 "Data Load MX"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    var
        CountryCodeTxt: Label 'MX', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Data Load", 'OnAfterW1DataLoadForVersion', '', false, false)]
    local procedure LoadDataForMX_16x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeTxt then
            exit;

        if TargetVersion <> 16.0 then
            exit;

        LoadDataExchDef(HybridReplicationSummary);
    end;

    local procedure LoadDataExchDef(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        DataExchDef: Record "Data Exch. Def";
        StgDataExchDef: Record "Stg Data Exch Def MX";
        W1DataLoad: Codeunit "W1 Data Load";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetGenJnlLineEFTExportSequenceNoUpgradeTag()) then
            exit;

        if StgDataExchDef.FindSet(false, false) then
            repeat
                DataExchDef.SetRange(Code, StgDataExchDef.Code);
                if DataExchDef.FindFirst() then begin
                    DataExchDef.TransferFields(StgDataExchDef);
                    DataExchDef.Modify();
                end;
            until StgDataExchDef.Next() = 0;

        W1DataLoad.OnAfterCompanyTableLoad(StgDataExchDef.RecordId().TableNo(), HybridReplicationSummary."Synced Version");
        StgDataExchDef.Reset();
        StgDataExchDef.DeleteAll();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetGenJnlLineEFTExportSequenceNoUpgradeTag());
    end;
}