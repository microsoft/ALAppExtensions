codeunit 11776 "Bank Account Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnAfterValidateEvent', 'Bank Acc. Posting Group', false, false)]
    local procedure CheckChangeBankAccPostingGroupOnAfterBankAccPostingGroupValidate(var Rec: Record "Bank Account"; var xRec: Record "Bank Account")
    begin
        if Rec."Bank Acc. Posting Group" <> xRec."Bank Acc. Posting Group" then
            Rec.CheckOpenBankAccLedgerEntriesCZL();
    end;
}