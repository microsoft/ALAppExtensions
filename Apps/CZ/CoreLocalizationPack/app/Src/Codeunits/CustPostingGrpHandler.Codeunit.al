codeunit 31035 "Cust. Posting Grp. Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteSubstPostingGroupsCZLOnAfterDelete(var Rec: Record "Customer Posting Group")
    var
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
    begin
        SubstCustPostingGroupCZL.SetRange("Parent Customer Posting Group", Rec.Code);
        SubstCustPostingGroupCZL.DeleteAll();
        SubstCustPostingGroupCZL.Reset();
        SubstCustPostingGroupCZL.SetRange("Customer Posting Group", Rec.Code);
        SubstCustPostingGroupCZL.DeleteAll();
    end;

    [Obsolete('This procedure will be removed after removing feature from Base Application.', '18.0')]
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeCheckOpenCustLedgEntries', '', false, false)]
#pragma warning restore AL0432
    local procedure DisableCheckOpenCustLedgEntries(var Prepayment1: Boolean; var IsHandled: Boolean);
    begin
        IsHandled := true; // Disable BaseApp CheckOpenCustLedgEntries replaced by Core app CheckOpenCustLedgEntriesCZL.
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterValidateEvent', 'Receivables Account', false, false)]
    local procedure CheckOpenCustLedgEntriesOnAfterValidateReceivablesAccount(var Rec: Record "Customer Posting Group")
    begin
        Rec.CheckOpenCustLedgEntriesCZL(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertDtldCustLedgEntry', '', false, false)]
    local procedure OnBeforeInsertDtldCustLedgEntry(var DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.Get(DtldCVLedgEntryBuffer."CV Ledger Entry No.");
        DtldCustLedgEntry."Customer Posting Group CZL" := CustLedgerEntry."Customer Posting Group";
    end;
}