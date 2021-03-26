tableextension 11746 "Bank Account CZL" extends "Bank Account"
{
    fields
    {
        field(11751; "Excl. from Exch. Rate Adj. CZL"; Boolean)
        {
            Caption = 'Exclude from Exch. Rate Adj.';
            DataClassification = CustomerContent;            

            trigger OnValidate()
            begin
                if "Excl. from Exch. Rate Adj. CZL" then begin
                    TestField("Currency Code");
                    if not ConfirmManagement.GetResponseOrDefault(ExcludeEntriesQst, false) then
                        "Excl. from Exch. Rate Adj. CZL" := xRec."Excl. from Exch. Rate Adj. CZL";
                end;
            end;
        }
    }
    procedure CheckOpenBankAccLedgerEntriesCZL()
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get("No.");
        BankAccount.CalcFields(Balance, "Balance (LCY)");
        BankAccount.TestField(Balance, 0);
        BankAccount.TestField("Balance (LCY)", 0);
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        ExcludeEntriesQst: Label 'All entries will be excluded from Exchange Rates Adjustment. Do you want to continue?';
}