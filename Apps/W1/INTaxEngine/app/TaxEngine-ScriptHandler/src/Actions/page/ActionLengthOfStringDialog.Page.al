page 20169 "Action Length Of String Dialog"
{
    Caption = 'Length of Strng';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Length Of String";
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
                            "Symbol Data Type"::NUMBER,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::NUMBER,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;
                }
                field("String Lookup"; VariableValue)
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
            }
        }
    }

    procedure SetCurrentRecord(var ActionLengthOfString2: Record "Action Length Of String");
    begin
        ActionLengthOfString := ActionLengthOfString2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionLengthOfString."Case ID");
        SetRange("Script ID", ActionLengthOfString."Script ID");
        SetRange(ID, ActionLengthOfString.ID);
        FilterGroup := 0;

        ScriptSymbolsMgmt.SetContext(ActionLengthOfString."Case ID", ActionLengthOfString."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionLengthOfString.TestField("Case ID");
        ActionLengthOfString.TestField("Script ID");
        ActionLengthOfString.TestField(ID);
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
        ActionLengthOfString: Record "Action Length Of String";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableValue: Text;
        VariableName2: Text[30];
}