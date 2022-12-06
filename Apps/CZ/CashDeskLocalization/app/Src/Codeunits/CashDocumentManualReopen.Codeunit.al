codeunit 31451 "Cash Document Manual Reopen"
{
    TableNo = "Cash Document Header CZP";

    trigger OnRun()
    var
        CashDocumentReleasesCZP: Codeunit "Cash Document-Release CZP";
    begin
        CashDocumentReleasesCZP.PerformManualReopen(Rec);
    end;
}