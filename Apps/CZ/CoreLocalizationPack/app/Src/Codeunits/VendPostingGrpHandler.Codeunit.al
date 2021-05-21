codeunit 31036 "Vend. Posting Grp. Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteSubstPostingGroupsCZLOnAfterDelete(var Rec: Record "Vendor Posting Group")
    var
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
    begin
        SubstVendPostingGroupCZL.SetRange("Parent Vendor Posting Group", Rec.Code);
        SubstVendPostingGroupCZL.DeleteAll();
        SubstVendPostingGroupCZL.Reset();
        SubstVendPostingGroupCZL.SetRange("Vendor Posting Group", Rec.Code);
        SubstVendPostingGroupCZL.DeleteAll();
    end;

    [Obsolete('This procedure will be removed after removing feature from Base Application.', '18.0')]
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeCheckOpenVendLedgEntries', '', false, false)]
#pragma warning restore AL0432
    local procedure DisableCheckOpenVendLedgEntries(var Prepayment1: Boolean; var IsHandled: Boolean);
    begin
        IsHandled := true; // Disable BaseApp CheckOpenVendLedgEntries replaced by Core app CheckOpenVendLedgEntriesCZL.
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterValidateEvent', 'Payables Account', false, false)]
    local procedure CheckOpenCustLedgEntriesOnAfterValidatePayablesAccount(var Rec: Record "Vendor Posting Group")
    begin
        Rec.CheckOpenVendLedgEntriesCZL(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertDtldVendLedgEntry', '', false, false)]
    local procedure UpdateVendorPostingGroupCZLOnBeforeInsertDtldVendLedgEntry(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.Get(DtldCVLedgEntryBuffer."CV Ledger Entry No.");
        DtldVendLedgEntry."Vendor Posting Group CZL" := VendorLedgerEntry."Vendor Posting Group";
    end;
}