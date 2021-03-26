codeunit 20296 "Use Case Serialization"
{
    procedure TableRelationToString(CaseID: Guid; ID: Guid): Text;
    var
        TaxTableRelation: Record "Tax Table Relation";
        TableName2: Text;
        Filters: Text;
        WhereConditionLbl: Label '"%1" where %2', Comment = '%1 = Table name, %2 = Filters';
    begin
        if IsNullGuid(ID) then
            exit;

        TaxTableRelation.GET(CaseID, ID);
        TableName2 := AppObjectHelper.GetObjectName(ObjectType::Table, TaxTableRelation."Source ID");
        Filters := LookupSerialization.TableFilterToString(
            CaseID,
            EmptyGuid,
            TaxTableRelation."Table Filter ID");
        exit(StrSubstNo(WhereConditionLbl, TableName2, Filters));
    end;

    procedure ComponentExpressionToString(CaseID: Guid; ID: Guid): Text;
    var
        TaxComponentExpression: Record "Tax Component Expression";
        VariableName: Text;
        ToStringFormatTxt: Label 'Calculate value of "%1", %2 (Output to Variable: %3)', Comment = '%1 - Expression, %2 - Token Strin, %3 - Component Name';
    begin
        ScriptSymbolsMgmt.SetContext(CaseID, EmptyGuid);
        TaxComponentExpression.GET(CaseID, ID);
        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Component, TaxComponentExpression."Component ID");
        exit(
            StrSubstNo(
                ToStringFormatTxt,
                TaxComponentExpression.Expression,
                ComponentExprTokenToString(TaxComponentExpression),
                VariableName));
    end;

    local procedure ComponentExprTokenToString(
        var TaxComponentExpression: Record "Tax Component Expression"): Text;
    var
        TaxComponentExprToken: Record "Tax Component Expr. Token";
        LookupVariableName: Text;
        LineText: Text;
        ToStringText: Text;
        ToStringFormatTxt: Label '%1 equals %2', Comment = '%1 - Token, %2 - Lookup Value';
    begin
        TaxComponentExprToken.Reset();
        TaxComponentExprToken.SetRange("Case ID", TaxComponentExpression."Case ID");
        TaxComponentExprToken.SetRange("Component Expr. ID", TaxComponentExpression.ID);
        if TaxComponentExprToken.FindSet() then
            repeat
                LookupVariableName := LookupSerialization.ConstantOrLookupText(
                    TaxComponentExprToken."Case ID",
                    TaxComponentExprToken."Script ID",
                    TaxComponentExprToken."Value Type",
                    TaxComponentExprToken.Value,
                    TaxComponentExprToken."Lookup ID",
                    "Symbol Data Type"::NUMBER);

                LineText := StrSubstNo(ToStringFormatTxt, TaxComponentExprToken.Token, LookupVariableName);
                if ToStringText <> '' then
                    ToStringText += ', ';
                ToStringText += LineText;
            until TaxComponentExprToken.Next() = 0;

        exit(ToStringText);
    end;

    local procedure VariableToString(VariableName: Text): Text;
    var
        VariableName2: Text;
        VariableFormatTxt: Label '"%1"', Comment = '%1 = Variable name';
    begin
        VariableName2 := DELCHR(VariableName, '<>=', '."\/''%][ ');
        if VariableName2 <> VariableName then
            exit(StrSubstNo(VariableFormatTxt, VariableName))
        else
            exit(VariableName);
    end;

    local procedure AttributeTableToString(ScriptSymbolLookup: Record "Script Symbol Lookup"): Text;
    var
        TableName2: Text;
        FieldName2: Text;
        TableFilters: Text;
        MethodText: Text;
        FromFieldName: Text;
        ToStringFormatWithFiltersTxt: Label 'value of %1 from %2 (where %3)', Comment = '%1 - Field Name, %2 - Table Name, %3 - Filters';
        ToStringFormatTxt: Label 'value of %1 from %2', Comment = '%1 - Field Name, %2 - Table Name';
    begin
        TableName2 := AppObjectHelper.GetObjectName(ObjectType::Table, ScriptSymbolLookup."Source ID");
        FieldName2 := ScriptSymbolsMgmt.GetSymbolName(
            "Symbol Type"::"Tax Attributes",
            ScriptSymbolLookup."Source Field ID");

        MethodText := LOWERCASE(Format(ScriptSymbolLookup."Table Method"));
        FromFieldName := VariableToString(FieldName2);

        if not IsNullGuid(ScriptSymbolLookup."Table Filter ID") then begin
            TableFilters := LookupSerialization.TableFilterToString(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID", ScriptSymbolLookup."Table Filter ID");
            if TableFilters <> '' then
                exit(StrSubstNo(ToStringFormatWithFiltersTxt, FromFieldName, VariableToString(TableName2), TableFilters));
        end;

        exit(StrSubstNo(ToStringFormatTxt, FromFieldName, VariableToString(TableName2)));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Lookup Serialization", 'OnSerializeLookupToString', '', false, false)]
    local procedure OnSerializeLookupToString(ScriptSymbolLookup: Record "Script Symbol Lookup"; var SerializedText: Text)
    var
        TableFieldName: Text;
        SymbolFormatTxt: Label '%1: %2', Comment = '%1 = Source type, %2 = Variable name';
    begin
        ScriptSymbolsMgmt.SetContext(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID");
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::"Attribute Table":
                SerializedText := AttributeTableToString(ScriptSymbolLookup);
            else begin
                    TableFieldName := ScriptSymbolsMgmt.GetSymbolName(
                        ScriptSymbolLookup."Source Type",
                        ScriptSymbolLookup."Source Field ID");
                    SerializedText := StrSubstNo(
                        SymbolFormatTxt,
                        ScriptSymbolLookup."Source Type",
                        VariableToString(TableFieldName));
                end;
        end;

    end;

    var
        AppObjectHelper: Codeunit "App Object Helper";
        LookupSerialization: Codeunit "Lookup Serialization";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        EmptyGuid: Guid;
}