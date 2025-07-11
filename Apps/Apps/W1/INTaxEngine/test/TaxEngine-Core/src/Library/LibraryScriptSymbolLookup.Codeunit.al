codeunit 136705 "Library - Script Symbol Lookup"
{
    EventSubscriberInstance = Manual;
    procedure CreateLookup(CaseID: Guid; ScriptID: Guid; TableID: Integer; FieldID: Integer; SourceType: Enum "Symbol Type") ID: Guid
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
    begin
        ID := LookupEntityMgmt.CreateLookup(CaseID, ScriptID);
        ScriptSymbolLookup.Get(CaseID, ScriptID, ID);
        ScriptSymbolLookup."Source Type" := SourceType;
        ScriptSymbolLookup."Source ID" := TableID;
        ScriptSymbolLookup."Source Field ID" := FieldID;
        ScriptSymbolLookup.Modify();
    end;

    procedure CreateLookup(CaseID: Guid; ScriptID: Guid; TableID: Integer; FieldID: Integer; SourceType: Enum "Symbol Type"; TableMethod: Option " ",First,Last,"Sum","Average","Min","Max","Count","Exist") ID: Guid
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
    begin
        ID := LookupEntityMgmt.CreateLookup(CaseID, ScriptID);
        ScriptSymbolLookup.Get(CaseID, ScriptID, ID);
        ScriptSymbolLookup."Source Type" := SourceType;
        ScriptSymbolLookup."Source ID" := TableID;
        ScriptSymbolLookup."Source Field ID" := FieldID;
        ScriptSymbolLookup."Table Method" := TableMethod;
        ScriptSymbolLookup.Modify();
    end;

    procedure CreateTableFilter(CaseID: Guid; ScriptID: Guid; TableID: Integer; FieldID: Integer) ID: Guid
    var
        LookupTableFilter: Record "Lookup Table Filter";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
    begin
        ID := LookupEntityMgmt.CreateTableFilters(CaseID, ScriptID, TableID);
        LookupTableFilter.Get(CaseID, ScriptID, ID);

        LookupFieldFilter.Init();
        LookupFieldFilter."Case ID" := CaseID;
        LookupFieldFilter."Script ID" := ScriptID;
        LookupFieldFilter."Table Filter ID" := ID;
        LookupFieldFilter."Table ID" := TableID;
        LookupFieldFilter."Field ID" := FieldID;
        LookupFieldFilter."Filter Type" := LookupFieldFilter."Filter Type"::Equals;
        LookupFieldFilter.Insert();
    end;

    procedure CreateTableSorting(CaseID: Guid; ScriptID: Guid; TableID: Integer; FieldIDList: List of [Integer]) ID: Guid
    var
        LookupTableSorting: Record "Lookup Table Sorting";
        LookupFieldSorting: Record "Lookup Field Sorting";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        I: Integer;
    begin
        ID := LookupEntityMgmt.CreateTableSorting(CaseID, ScriptID, TableID);
        LookupTableSorting.Get(CaseID, ScriptID, ID);

        for I := 1 to FieldIDList.Count() do begin
            clear(LookupFieldSorting);
            LookupFieldSorting.Init();
            LookupFieldSorting."Case ID" := CaseID;
            LookupFieldSorting."Script ID" := ScriptID;
            LookupFieldSorting."Line No." := I;
            LookupFieldSorting."Table Sorting ID" := ID;
            LookupFieldSorting."Table ID" := TableID;
            LookupFieldSorting."Field ID" := FieldIDList.Get(I);
            LookupFieldSorting.Insert();
        end;
    end;

    procedure SetContext(var ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.")
    var
        TaxType: Code[20];
        CaseID: Guid;
        ScriptID: Guid;
    begin
        TaxType := 'TAX';
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        ScriptSymbolsMgmt.SetContext(TaxType, CaseID, ScriptID);
    end;

    procedure SetContextWithoutTaxType(var ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.")
    var
        CaseID: Guid;
        ScriptID: Guid;
    begin
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        ScriptSymbolsMgmt.SetContext(CaseID, ScriptID);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbols Mgmt.", 'OnInitScriptSymbols', '', false, false)]
    local procedure OnInitScriptSymbols(var Symbols: Record "Script Symbol"; sender: Codeunit "Script Symbols Mgmt.")
    begin
        sender.InsertScriptSymbol("Symbol Type"::System, 5000, 'TEST SYMBOL', "Symbol Data Type"::STRING);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Lookup Mgmt.", 'OnGetLookupSourceTableID', '', false, false)]
    local procedure OnGetLookupSourceTableID(CaseID: Guid; var Handled: Boolean; var TableID: Integer)
    begin
        if IsNullGuid(CaseID) then
            exit;

        if CaseID <> '3089bc6c-c971-4ee9-a96a-3df5ebb63571' then //caseID hardcoded only for automation test. 
            TableID := Database::"Sales Line";

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbols Mgmt.", 'OnGetTaxType', '', false, false)]
    local procedure OnGetTaxType(CaseID: Guid; var TaxType: Code[20]; var Handled: Boolean)
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        if IsNullGuid(CaseID) then
            exit;

        evaluate(TaxType, LibraryRandom.RandText(20));
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbol Store", 'OnInitSymbols', '', false, false)]
    local procedure OnInitSymbols(
        CaseID: Guid;
        ScriptID: Guid;
        var Symbols: Record "Script Symbol Value" Temporary;
        var sender: Codeunit "Script Symbol Store")
    begin
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::BOOLEAN, 5000);
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::DATE, 5001);
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::DATETIME, 5002);
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::Guid, 5003);
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::NUMBER, 5004);
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::OPTION, 5005);
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::RECID, 5006);
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::RECORD, 5007);
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::STRING, 5008);
        sender.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::TIME, 5009);
    end;
}