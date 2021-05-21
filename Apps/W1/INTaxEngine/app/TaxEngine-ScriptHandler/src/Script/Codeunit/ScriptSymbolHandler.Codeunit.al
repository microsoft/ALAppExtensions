codeunit 20168 "Script Symbol Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbols Mgmt.", 'OnInitScriptSymbols', '', false, false)]
    procedure OnInitScriptSymbols(
            var sender: Codeunit "Script Symbols Mgmt.";
            TaxType: Code[20];
            CaseID: Guid;
            ScriptID: Guid;
            var Symbols: Record "Script Symbol" temporary);
    var
        ScriptVariable: Record "Script Variable";
    begin
        ScriptVariable.Reset();
        ScriptVariable.SetRange("Case ID", CaseID);
        ScriptVariable.SetRange("Script ID", ScriptID);
        if ScriptVariable.FindSet() then
            repeat
                sender.InsertScriptSymbol("Symbol Type"::Variable, ScriptVariable.ID, ScriptVariable.Name, ScriptVariable.Datatype);
            until ScriptVariable.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbol Store", 'OnInitSymbols', '', false, false)]
    local procedure OnInitSymbols(CaseID: Guid; ScriptID: Guid; sender: Codeunit "Script Symbol Store"; var Symbols: Record "Script Symbol Value")
    var
        ScriptVariable: Record "Script Variable";
        ScriptRecordVariable: Record "Script Record Variable";
        Value: Variant;
    begin
        ScriptVariable.Reset();
        ScriptVariable.SetRange("Case ID", CaseID);
        ScriptVariable.SetRange("Script ID", ScriptID);
        if ScriptVariable.FindSet() then
            repeat
                Symbols.SetRange("Symbol ID", ScriptVariable.ID);
                Symbols.SetRange(Type, "Symbol Type"::Variable);
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);
                    sender.InsertSymbolValue("Symbol Type"::Variable, ScriptVariable.Datatype, ScriptVariable.ID, Value);
                end else
                    sender.InsertSymbolValue("Symbol Type"::Variable, ScriptVariable.Datatype, ScriptVariable.ID);

                if ScriptVariable.Datatype = "Symbol Data Type"::RECORD then begin
                    ScriptRecordVariable.Reset();
                    ScriptRecordVariable.SetRange("Case ID", CaseID);
                    ScriptRecordVariable.SetRange("Script ID", ScriptID);
                    ScriptRecordVariable.SetRange("Variable ID", ScriptVariable.ID);
                    if ScriptRecordVariable.FindSet() then
                        repeat
                            sender.InsertDictionaryValue(ScriptRecordVariable.Datatype, ScriptRecordVariable."Variable ID", ScriptRecordVariable.ID);
                        until ScriptRecordVariable.Next() = 0;
                end;
            until ScriptVariable.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbol Store", 'OnGetLookupValue', '', false, false)]
    local procedure OnGetLookupValue(sender: Codeunit "Script Symbol Store"; ScriptSymbolLookup: Record "Script Symbol Lookup"; var IsHandled: Boolean; var Value: Variant)
    begin
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::Variable:
                begin
                    sender.GetSymbolOfType("Symbol Type"::Variable, ScriptSymbolLookup."Source Field ID", Value);
                    IsHandled := true;
                end;
            ScriptSymbolLookup."Source Type"::"Record Variable":
                begin
                    sender.GetSymbolMember(
                        ScriptSymbolLookup."Source ID",
                        ScriptSymbolLookup."Source Field ID",
                        Value);
                    IsHandled := true;
                end;
        end;
    end;
}