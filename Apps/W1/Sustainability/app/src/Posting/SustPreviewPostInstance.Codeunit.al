codeunit 6233 "Sust. Preview Post Instance"
{
    SingleInstance = true;

    procedure InsertDocumentEntry(var TempDocumentEntry: Record "Document Entry" temporary)
    var
        RecRef: RecordRef;
    begin
        if not HasSustainabilityEntry then
            exit;

        RecRef.GetTable(TempSustLedgEntry);

        if RecRef.IsEmpty() then
            exit;

        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." := RecRef.Number;
        TempDocumentEntry."Table ID" := RecRef.Number;
        TempDocumentEntry."Table Name" := RecRef.Caption;
        TempDocumentEntry."No. of Records" := RecRef.Count();
        TempDocumentEntry.Insert();
    end;

    procedure InsertSustLedgEntry(var SustLedgEntry: Record "Sustainability Ledger Entry"; RunTrigger: Boolean)
    begin
        if SustLedgEntry.IsTemporary() then
            exit;

        TempSustLedgEntry := SustLedgEntry;
        TempSustLedgEntry."Document No." := '***';
        TempSustLedgEntry.Insert();
        HasSustainabilityEntry := true;
    end;

    procedure ShowEntries()
    begin
        Page.Run(Page::"Sustainability Ledger Entries", TempSustLedgEntry);
    end;

    procedure Initialize()
    begin
        ClearAll();
        TempSustLedgEntry.Reset();
        TempSustLedgEntry.DeleteAll();
    end;

    var
        TempSustLedgEntry: Record "Sustainability Ledger Entry" temporary;
        HasSustainabilityEntry: Boolean;
}