codeunit 31411 "Report Selection Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Report Selection Mgt.", 'OnAfterInitReportSelectionInvt', '', false, false)]
    local procedure InitInventoryDocumentReportsOnAfterInitReportSelectionInvt()
    begin
        InsertRepSelection(Enum::"Report Selection Usage"::"Inventory Receipt", '1', Report::"Inventory Document CZL");
        InsertRepSelection(Enum::"Report Selection Usage"::"Inventory Shipment", '1', Report::"Inventory Document CZL");
        InsertRepSelection(Enum::"Report Selection Usage"::"P.Inventory Receipt", '1', Report::"Posted Inventory Receipt CZL");
        InsertRepSelection(Enum::"Report Selection Usage"::"P.Inventory Shipment", '1', Report::"Posted Inventory Shipment CZL");
    end;

    local procedure InsertRepSelection(ReportUsage: Enum "Report Selection Usage"; Sequence: Code[10]; ReportID: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        if not ReportSelections.Get(ReportUsage, Sequence) then begin
            ReportSelections.Init();
            ReportSelections.Usage := ReportUsage;
            ReportSelections.Sequence := Sequence;
            ReportSelections."Report ID" := ReportID;
            ReportSelections.Insert();
        end else begin
            ReportSelections."Report ID" := ReportID;
            ReportSelections.Modify();
        end;
    end;
}