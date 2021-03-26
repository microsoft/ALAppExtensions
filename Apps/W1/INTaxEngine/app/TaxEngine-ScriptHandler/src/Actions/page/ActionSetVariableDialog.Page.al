page 20179 "Action Set Variable Dialog"
{
    Caption = 'Set Rule Variable Dialog';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Set Variable";

    layout
    {
        area(Content)
        {
            group(General)
            {

                field(VariableName; VariableName2)
                {
                    Caption = 'Output Variable';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specified the name of output variable in which the value will be stored';
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SetContext("Case ID", "Script ID");
                        ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::Variable, "Variable ID", VariableName2);
                        Validate("Variable ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookup(
                            "Symbol Type"::Variable,
                            Text,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;
                }
                field(LookupVariable; VariableValue)
                {
                    Caption = 'Value';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of variable, this can be either a constant value or it can be also derived from a Lookup.';
                    trigger OnValidate();
                    var
                        VariableDataType: Enum "Symbol Data Type";
                    begin
                        VariableDataType := ScriptSymbolsMgmt.GetSymbolDataType("Symbol Type"::Variable, "Variable ID");
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID",
                            VariableValue,
                            VariableDataType)
                        then
                            Validate(Value);

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialog("Case ID", "Script ID", "Lookup ID");
                            Validate("Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    var
        ActionSetVariable: Record "Action Set Variable";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableValue: Text;
        VariableName2: Text[30];

    procedure SetCurrentRecord(var ActionSetVariable2: Record "Action Set Variable");
    begin
        ActionSetVariable := ActionSetVariable2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionSetVariable."Case ID");
        SetRange("Script ID", ActionSetVariable."Script ID");
        SetRange(ID, ActionSetVariable.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionSetVariable."Case ID", ActionSetVariable."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionSetVariable.TestField("Case ID");
        ActionSetVariable.TestField("Script ID");
        ActionSetVariable.TestField(ID);
    end;

    local procedure FormatLine();
    var
        VariableDataType: Enum "Symbol Data Type";
    begin
        VariableDataType := ScriptSymbolsMgmt.GetSymbolDataType("Symbol Type"::Variable, "Variable ID");
        VariableValue := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Value Type",
            Value,
            "Lookup ID",
            VariableDataType);

        VariableName2 := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, "Variable ID");
    end;

    trigger OnOpenPage();
    begin
        TestRecord();
    end;

    trigger OnAfterGetRecord();
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;
}