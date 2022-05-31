codeunit 31273 "Vendor Handler CZC"
{
    Permissions = tabledata "Vendor Ledger Entry" = m;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateEntryOnAfterCopyVendorLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VendorLedgerEntry."Compensation CZC" := GenJournalLine."Compensation CZC";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnBeforeValidateEvent', 'On Hold', false, false)]
    local procedure CheckCompensationOnBeforeValidateOnHold(var Rec: Record "Vendor Ledger Entry")
    var
        GenJournalLine: Record "Gen. Journal Line";
        OnHoldErr: Label 'The operation is prohibited, until journal line of Journal Template Name = ''%1'', Journal Batch Name = ''%2'', Line No. = ''%3'' is deleted or posted.', Comment = '%1 = Template Name, %2 = Batch Name, %3 = Line No.';
    begin
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine.SetRange("Account No.", Rec."Vendor No.");
        GenJournalLine.SetRange("Applies-to Doc. Type", Rec."Document Type");
        GenJournalLine.SetRange("Applies-to Doc. No.", Rec."Document No.");
        GenJournalLine.SetRange("Compensation CZC", true);
        if GenJournalLine.FindFirst() then
            Error(OnHoldErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterOldVendLedgEntryModify', '', false, false)]
    local procedure ClearOnHoldOnAfterOldVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Compensation CZC" then begin
            VendLedgEntry."On Hold" := '';
            VendLedgEntry.Modify();
        end;
    end;
}
