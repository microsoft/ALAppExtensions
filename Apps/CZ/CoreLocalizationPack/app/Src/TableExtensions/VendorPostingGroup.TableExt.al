#if not CLEAN19
tableextension 11788 "Vendor Posting Group CZL" extends "Vendor Posting Group"
{
    [Obsolete('Replaced by GetPayablesAccNo in "Gen. Journal Line Handler CZL" codeunit', '19.0')]
    procedure GetPayablesAccNoCZL(PostingGroupCode: Code[20]; Advance: Boolean): Code[20]
    var
        PostingSetupManagement: Codeunit PostingSetupManagement;
    begin
        Get(PostingGroupCode);
#pragma warning disable AL0432
        if Advance then begin
            if "Advance Account" = '' then
                PostingSetupManagement.SendVendPostingGroupNotification(Rec, FieldCaption("Advance Account"));
            TestField("Advance Account");
            exit("Advance Account");
        end;
#pragma warning restore AL0432
        if "Payables Account" = '' then
            PostingSetupManagement.SendVendPostingGroupNotification(Rec, FieldCaption("Payables Account"));
        TestField("Payables Account");
        exit("Payables Account");
    end;

    [Obsolete('Replaced by CheckOpenVendLedgEntries in "C/V Posting Group Handler CZL" codeunit', '19.0')]
    procedure CheckOpenVendLedgEntriesCZL(IsPrepayment: Boolean)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ConfirmManagement: Codeunit "Confirm Management";
        FieldCaptionText: Text;
        ChangeAccountQst: Label 'Do you really want to change %1 although open entries exist?', Comment = '%1 = fieldcaption';
    begin
        VendorLedgerEntry.SetCurrentKey(Open);
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetRange("Vendor Posting Group", Rec.Code);
        VendorLedgerEntry.SetRange(Prepayment, IsPrepayment);
        if not VendorLedgerEntry.IsEmpty then begin
#pragma warning disable AL0432
            if IsPrepayment then
                FieldCaptionText := FieldCaption("Advance Account")
            else
#pragma warning restore AL0432
            FieldCaptionText := FieldCaption("Payables Account");
            if not ConfirmManagement.GetResponse(StrSubstNo(ChangeAccountQst, FieldCaptionText), false) then
                Error('');
        end;
    end;
}
#endif
