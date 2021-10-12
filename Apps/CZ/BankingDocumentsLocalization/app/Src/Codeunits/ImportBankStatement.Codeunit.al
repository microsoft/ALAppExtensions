codeunit 31399 "Import Bank Statement CZB"
{
    TableNo = "Bank Acc. Reconciliation";

    trigger OnRun()
    begin
        Rec.ImportBankStatement();
    end;
}
