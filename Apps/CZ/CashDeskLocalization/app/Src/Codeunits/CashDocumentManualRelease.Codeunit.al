codeunit 31450 "Cash Document Manual Release"
{
    TableNo = "Cash Document Header CZP";

    trigger OnRun()
    var
        CashDocumentReleasesCZP: Codeunit "Cash Document-Release CZP";
    begin
        CashDocumentReleasesCZP.PerformManualRelease(Rec);
    end;
}