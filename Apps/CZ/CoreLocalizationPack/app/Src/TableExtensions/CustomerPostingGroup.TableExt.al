tableextension 11787 "Customer Posting Group CZL" extends "Customer Posting Group"
{
    procedure GetReceivablesAccNoCZL(PostingGroupCode: Code[20]; Advance: Boolean): Code[20]
    var
        PostingSetupManagement: Codeunit PostingSetupManagement;
    begin
        Get(PostingGroupCode);
        if Advance then begin
            if "Advance Account" = '' then
                PostingSetupManagement.SendCustPostingGroupNotification(Rec, FieldCaption("Advance Account"));
            TestField("Advance Account");
            exit("Advance Account");
        end;
        if "Receivables Account" = '' then
            PostingSetupManagement.SendCustPostingGroupNotification(Rec, FieldCaption("Receivables Account"));
        TestField("Receivables Account");
        exit("Receivables Account");
    end;

    procedure CheckOpenCustLedgEntriesCZL(IsPrepayment: Boolean)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ConfirmManagement: Codeunit "Confirm Management";
        FieldCaptionText: Text;
        ChangeAccountQst: Label 'Do you really want to change %1 although open entries exist?', Comment = '%1 = fieldcaption';
    begin
        CustLedgerEntry.SetCurrentKey(Open);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange("Customer Posting Group", Rec.Code);
        CustLedgerEntry.SetRange(Prepayment, IsPrepayment);
        if not CustLedgerEntry.IsEmpty then begin
            if IsPrepayment then
                FieldCaptionText := FieldCaption("Advance Account")
            else
                FieldCaptionText := FieldCaption("Receivables Account");
            if not ConfirmManagement.GetResponse(StrSubstNo(ChangeAccountQst, FieldCaptionText), false) then
                Error('');
        end;
    end;
}