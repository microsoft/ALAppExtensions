pageextension 31152 "Bank Account Ledg. Entries CZP" extends "Bank Account Ledger Entries"
{
    trigger OnOpenPage()
    var
        BankAccount: Record "Bank Account";
        BankAccountNo: Code[20];
        CashDeskLedgerEntriesTxt: Label 'Cash Desk Ledger Entries';
    begin
        if Rec.GetFilter("Bank Account No.") <> '' then
            BankAccountNo := Rec.GetRangeMin("Bank Account No.");
        if BankAccountNo = '' then begin
            Rec.FilterGroup(2);
            if Rec.GetFilter("Bank Account No.") <> '' then
                BankAccountNo := Rec.GetRangeMin("Bank Account No.");
            Rec.FilterGroup(0);
        end;
        if BankAccountNo = '' then
            exit;
        if BankAccount.Get(BankAccountNo) then
            if BankAccount."Account Type CZP" = BankAccount."Account Type CZP"::"Cash Desk" then
                Caption := CashDeskLedgerEntriesTxt;
    end;
}
