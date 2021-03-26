page 20158 "Action Convert Case Dialog"
{
    Caption = 'Convert case of String';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Convert Case";
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
                    ToolTip = 'Specifies the variable name which will store the output.';
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SearchSymbolOfType(
                            "Symbol Type"::Variable,
                            "Symbol Data Type"::STRING,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::STRING,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;
                }
                field("VariableLookup"; VariableValue)
                {
                    Caption = 'String';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of string.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID",
                            VariableValue,
                            "Symbol Data Type"::STRING)
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

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Lookup ID",
                                "Symbol Data Type"::STRING);
                            Validate("Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field("Convert To Case"; "Convert To Case")
                {
                    Caption = 'Convert To Case';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the converted case.';
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionConvertCase2: Record "Action Convert Case");
    begin
        ActionConvertCase := ActionConvertCase2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionConvertCase."Case ID");
        SetRange("Script ID", ActionConvertCase."Script ID");
        SetRange(ID, ActionConvertCase.ID);
        FilterGroup := 0;

        ScriptSymbolsMgmt.SetContext(ActionConvertCase."Case ID", ActionConvertCase."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionConvertCase.TestField("Case ID");
        ActionConvertCase.TestField("Script ID");
        ActionConvertCase.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        VariableValue := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Value Type",
            Value,
            "Lookup ID",
            "Symbol Data Type"::STRING);
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

    var
        ActionConvertCase: Record "Action Convert Case";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableValue: Text;
        VariableName2: Text[30];
}