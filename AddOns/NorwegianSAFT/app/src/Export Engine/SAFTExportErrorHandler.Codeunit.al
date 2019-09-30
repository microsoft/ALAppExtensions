codeunit 10676 "SAF-T Export Error Handler"
{
    TableNo = "SAF-T Export Line";
    trigger OnRun()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
    begin
        SAFTExportMgt.LogError(Rec);
        LockTable();
        Status := Status::Failed;
        Progress := 100;
        if "No. Of Retries" > 0 then
            "No. Of Retries" -= 1;
        Modify(true);
        SAFTExportHeader.Get(ID);
        SAFTExportMgt.UpdateExportStatus(SAFTExportHeader);
        SAFTExportMgt.SendTraceTagOfExport(SAFTExportTxt, GetCancelTraceTagMessage(Rec));
        SAFTExportMgt.StartExportLinesNotStartedYet(SAFTExportHeader);
    end;

    var
        FailedExportTxt: Label 'Failed SAF-T export with ID: %1, Task ID: %2', Comment = '%1 - integer; %2 - GUID';
        SAFTExportTxt: Label 'SAF-T export';

    local procedure GetCancelTraceTagMessage(SAFTExportLine: Record "SAF-T Export Line"): Text
    begin
        exit(StrSubstNo(FailedExportTxt, SAFTExportLine.ID, SAFTExportLine."Task ID"));
    end;
}