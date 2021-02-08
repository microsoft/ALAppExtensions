tableextension 11746 "Bank Account CZL" extends "Bank Account"
{
    procedure CheckOpenBankAccLedgerEntriesCZL()
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get("No.");
        BankAccount.CalcFields(Balance, "Balance (LCY)");
        BankAccount.TestField(Balance, 0);
        BankAccount.TestField("Balance (LCY)", 0);
    end;
}