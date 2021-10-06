#if not CLEAN19
tableextension 11787 "Customer Posting Group CZL" extends "Customer Posting Group"
{
    [Obsolete('Replaced by GetReceivablesAccNo in "Gen. Journal Line Handler CZL" codeunit', '19.0')]
    procedure GetReceivablesAccNoCZL(PostingGroupCode: Code[20]; Advance: Boolean): Code[20]
    var
        PostingSetupManagement: Codeunit PostingSetupManagement;
    begin
        Get(PostingGroupCode);
#pragma warning disable AL0432
        if Advance then begin
            if "Advance Account" = '' then
                PostingSetupManagement.SendCustPostingGroupNotification(Rec, FieldCaption("Advance Account"));
            TestField("Advance Account");
            exit("Advance Account");
        end;
#pragma warning restore AL0432
        if "Receivables Account" = '' then
            PostingSetupManagement.SendCustPostingGroupNotification(Rec, FieldCaption("Receivables Account"));
        TestField("Receivables Account");
        exit("Receivables Account");
    end;

    [Obsolete('Replaced by CheckOpenCustLedgEntries in "C/V Posting Group Handler CZL" codeunit', '19.0')]
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
#pragma warning disable AL0432            
                FieldCaptionText := FieldCaption("Advance Account")
#pragma warning restore AL0432
            else
                FieldCaptionText := FieldCaption("Receivables Account");
            if not ConfirmManagement.GetResponse(StrSubstNo(ChangeAccountQst, FieldCaptionText), false) then
                Error('');
        end;
    end;
}
#endif
