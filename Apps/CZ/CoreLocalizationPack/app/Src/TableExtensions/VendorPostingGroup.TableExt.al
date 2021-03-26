tableextension 11788 "Vendor Posting Group CZL" extends "Vendor Posting Group"
{
    procedure GetPayablesAccNoCZL(PostingGroupCode: Code[20]; Advance: Boolean): Code[20]
    var
        PostingSetupManagement: Codeunit PostingSetupManagement;
    begin
        Get(PostingGroupCode);
        if Advance then begin
            if "Advance Account" = '' then
                PostingSetupManagement.SendVendPostingGroupNotification(Rec, FieldCaption("Advance Account"));
            TestField("Advance Account");
            exit("Advance Account");
        end;
        if "Payables Account" = '' then
            PostingSetupManagement.SendVendPostingGroupNotification(Rec, FieldCaption("Payables Account"));
        TestField("Payables Account");
        exit("Payables Account");
    end;

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
            if IsPrepayment then
                FieldCaptionText := FieldCaption("Advance Account")
            else
                FieldCaptionText := FieldCaption("Payables Account");
            if not ConfirmManagement.GetResponse(StrSubstNo(ChangeAccountQst, FieldCaptionText), false) then
                Error('');
        end;
    end;

}