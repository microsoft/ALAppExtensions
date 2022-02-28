codeunit 1694 "Posted Bank Deposit-Delete"
{
    Permissions = TableData "Posted Bank Deposit Header" = rd,
                  TableData "Posted Bank Deposit Line" = rd;
    TableNo = "Posted Bank Deposit Header";

    trigger OnRun()
    begin
        PostedBankDepositLine.SetRange("Bank Deposit No.", "No.");
        PostedBankDepositLine.DeleteAll();

        OnRunOnBeforeDelete(Rec);
        Delete();
    end;

    var
        PostedBankDepositLine: Record "Posted Bank Deposit Line";

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeDelete(var PostedBankDepositHeader: Record "Posted Bank Deposit Header")
    begin
    end;
}

