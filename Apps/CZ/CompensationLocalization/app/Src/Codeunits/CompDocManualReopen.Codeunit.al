codeunit 31458 "Comp. Doc. Manual Reopen CZC"
{
    TableNo = "Compensation Header CZC";

    trigger OnRun()
    var
        ReleaseCompensDocument: Codeunit "Release Compens. Document CZC";
    begin
        ReleaseCompensDocument.PerformManualReopen(Rec);
    end;
}