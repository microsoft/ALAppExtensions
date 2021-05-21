codeunit 11723 "Data Load CZ"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';
    Permissions = tabledata "Item Ledger Entry" = rmid, tabledata "Item Journal Line" = rmid, tabledata "Intrastat Jnl. Line" = rmid;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Data Load", 'OnAfterW1DataLoadForVersion', '', false, false)]
    local procedure LoadDataForCZ_18x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeTxt then
            exit;

        if TargetVersion <> 18.0 then
            exit;

        LoadIntrastatJnlLine(HybridReplicationSummary);
        LoadItemJournalLine(HybridReplicationSummary);
        LoadItemLedgerEntry(HybridReplicationSummary);
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

    local procedure LoadIntrastatJnlLine(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        StgIntrastatJnlLine: Record "Stg Intrastat Jnl. Line";
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
        W1DataLoad: Codeunit "W1 Data Load";
    begin
        StgIntrastatJnlLine.SetFilter("Shipment Method Code", '<>%1', '');
        if StgIntrastatJnlLine.FindSet() then
            repeat
                if IntrastatJnlLine.Get(StgIntrastatJnlLine."Journal Template Name", StgIntrastatJnlLine."Journal Batch Name", StgIntrastatJnlLine."Line No.") then begin
                    IntrastatJnlLine.TransferFields(StgIntrastatJnlLine);
                    IntrastatJnlLine.Modify();
                end;
            until StgIntrastatJnlLine.Next() = 0;

        W1DataLoad.OnAfterCompanyTableLoad(IntrastatJnlLine.RecordId().TableNo(), HybridReplicationSummary."Synced Version");
        StgIntrastatJnlLine.Reset();
        StgIntrastatJnlLine.DeleteAll();
    end;

    local procedure LoadItemJournalLine(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        StgItemJournalLine: Record "Stg Item Journal Line";
        ItemJournalLine: Record "Item Journal Line";
        W1DataLoad: Codeunit "W1 Data Load";
    begin
        StgItemJournalLine.SetFilter("Shipment Method Code", '<>%1', '');
        if StgItemJournalLine.FindSet() then
            repeat
                if ItemJournalLine.Get(StgItemJournalLine."Journal Template Name", StgItemJournalLine."Journal Batch Name", StgItemJournalLine."Line No.") then begin
                    ItemJournalLine.TransferFields(StgItemJournalLine);
                    ItemJournalLine.Modify();
                end;
            until StgItemJournalLine.Next() = 0;

        W1DataLoad.OnAfterCompanyTableLoad(ItemJournalLine.RecordId().TableNo(), HybridReplicationSummary."Synced Version");
        StgItemJournalLine.Reset();
        StgItemJournalLine.DeleteAll();
    end;

    local procedure LoadItemLedgerEntry(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        StgItemLedgerEntry: Record "Stg Item Ledger Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        W1DataLoad: Codeunit "W1 Data Load";
    begin
        StgItemLedgerEntry.SetFilter("Shipment Method Code", '<>%1', '');
        if StgItemLedgerEntry.FindSet() then
            repeat
                if ItemLedgerEntry.Get(StgItemLedgerEntry."Entry No.") then begin
                    ItemLedgerEntry.TransferFields(StgItemLedgerEntry);
                    ItemLedgerEntry.Modify();
                end;
            until StgItemLedgerEntry.Next() = 0;

        W1DataLoad.OnAfterCompanyTableLoad(ItemLedgerEntry.RecordId().TableNo(), HybridReplicationSummary."Synced Version");
        StgItemLedgerEntry.Reset();
        StgItemLedgerEntry.DeleteAll();
    end;
}