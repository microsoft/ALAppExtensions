namespace Microsoft.Bank.Deposit;

codeunit 1693 "Bank Deposit-Printed"
{
    Permissions = TableData "Posted Bank Deposit Header" = rm;
    TableNo = "Posted Bank Deposit Header";

    trigger OnRun()
    begin
        Rec.Find();
        Rec."No. Printed" := Rec."No. Printed" + 1;
        Rec.Modify();
        Commit();
    end;
}



