page 20309 "Use Case Rate Column Relation"
{
    PageType = ListPart;
    SourceTable = "Use Case Rate Column Relation";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; SetupColumnName)
                {
                    Caption = 'Column Name';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the Rate column which will be mapped to this tax use case to find the tax rate, mapping is only needed for Range and Value type rate columns.';
                    trigger OnValidate()
                    begin
                        if IsNullGuid(id) then begin
                            Init();
                            "Case ID" := "Case ID";
                            ID := CreateGuid();
                            Insert();
                        end;
                        ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::Column, "Column ID", SetupColumnName);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookup("Symbol Type"::Column, SetupColumnName, "Column ID", SetupColumnName);
                    end;
                }
                field(TableRelation; MappingTxt)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the mapping of Rate column to get its value.';
                    ShowCaption = false;
                    Caption = 'Mapping';
                    Editable = false;
                    StyleExpr = true;
                    Style = Subordinate;
                    trigger OnAssistEdit()
                    begin
                        if IsNullGuid("Switch Statement ID") then begin
                            "Switch Statement ID" := SwitchStatementHelper.CreateSwitchStatement("Case ID");
                            CurrPage.SaveRecord();
                            Commit();
                        end;
                        SwitchStatementHelper.OpenSwitchStatements("Case ID", "Switch Statement ID", "Switch Case Action Type"::Lookup);
                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetupColumnName := '';
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    var
        SwitchCase: Record "Switch Case";
    begin
        ScriptSymbolsMgmt.SetContext("Case ID", EmptyGuid);

        if "Column ID" <> 0 then
            SetupColumnName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Column, "Column ID")
        else
            SetupColumnName := '';

        MappingTxt := '';

        SwitchCase.SetRange("Case ID", "Case ID");
        SwitchCase.SetRange("Switch Statement ID", "Switch Statement ID");
        if SwitchCase.FindSet() then
            repeat
                if MappingTxt <> '' then
                    MappingTxt += ', ';

                if not IsNullGuid(SwitchCase."Condition ID") then
                    MappingTxt += 'If ' + ScriptSerialization.ConditionToString("Case ID", EmptyGuid, SwitchCase."Condition ID") + ' Then ';

                MappingTxt += LookupSerialization.LookupToString("Case ID", EmptyGuid, SwitchCase."Action ID");
            until SwitchCase.Next() = 0
        else
            MappingTxt := '< Mapping >';
    end;

    var
        ScriptSerialization: Codeunit "Script Serialization";
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
        LookupSerialization: Codeunit "Lookup Serialization";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        EmptyGuid: Guid;
        MappingTxt: Text;
        SetupColumnName: Text[30];
}