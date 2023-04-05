codeunit 31457 "Comp. Doc. Manual Release CZC"
{
    TableNo = "Compensation Header CZC";

    trigger OnRun()
    var
        ReleaseCompensDocumentCZC: Codeunit "Release Compens. Document CZC";
    begin
        ReleaseCompensDocumentCZC.PerformManualRelease(Rec);
    end;
}