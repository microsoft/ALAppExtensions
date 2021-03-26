codeunit 11723 "Data Load CZ"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    var
        CountryCodeTxt: Label 'CZ', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Data Load", 'OnAfterW1DataLoadForVersion', '', false, false)]
    local procedure LoadDataForCZ_15x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeTxt then
            exit;

        if TargetVersion <> 15.0 then
            exit;

        LoadVATPostingSetup(HybridReplicationSummary);
        LoadVATControlReportLine(HybridReplicationSummary);
    end;

    local procedure LoadVATPostingSetup(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        StgVATPostingSetup: Record "Stg VAT Posting Setup";
        W1DataLoad: Codeunit "W1 Data Load";
    begin
        if StgVATPostingSetup.FindSet() then
            repeat
                if VATPostingSetup.Get(StgVATPostingSetup."VAT Bus. Posting Group", StgVATPostingSetup."VAT Prod. Posting Group") then begin
                    VATPostingSetup.TransferFields(StgVATPostingSetup);
                    VATPostingSetup.Modify();
                end;
            until StgVATPostingSetup.Next() = 0;

        W1DataLoad.OnAfterCompanyTableLoad(VATPostingSetup.RecordId().TableNo(), HybridReplicationSummary."Synced Version");
        StgVATPostingSetup.DeleteAll();
    end;

    local procedure LoadVATControlReportLine(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        VATControlReportLine: Record "VAT Control Report Line";
        StgVATControlReportLine: Record "Stg VAT Control Report Line";
        W1DataLoad: Codeunit "W1 Data Load";
    begin
        if StgVATControlReportLine.FindSet() then
            repeat
                if VATControlReportLine.Get(StgVATControlReportLine."Control Report No.", StgVATControlReportLine."Line No.") then begin
                    VATControlReportLine.TransferFields(StgVATControlReportLine);
                    VATControlReportLine.Modify();
                end;
            until StgVATControlReportLine.Next() = 0;

        W1DataLoad.OnAfterCompanyTableLoad(VATControlReportLine.RecordId().TableNo(), HybridReplicationSummary."Synced Version");
        StgVATControlReportLine.DeleteAll();
    end;
}