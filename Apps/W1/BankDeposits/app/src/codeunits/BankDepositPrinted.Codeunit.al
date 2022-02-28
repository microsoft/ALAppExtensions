codeunit 1693 "Bank Deposit-Printed"
{
    Permissions = TableData "Posted Bank Deposit Header" = rm;
    TableNo = "Posted Bank Deposit Header";

    trigger OnRun()
    begin
        Find();
        "No. Printed" := "No. Printed" + 1;
        Modify();
        Commit();
    end;
}

