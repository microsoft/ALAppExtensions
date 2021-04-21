page 20161 "Action Extract Date Part Dlg"
{
    Caption = 'Extract Date';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Extract Date Part";

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
                field("Date Lookup"; VariableValue)
                {
                    Caption = 'Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of date.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID",
                            VariableValue,
                            "Symbol Data Type"::DATE)
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
                                "Symbol Data Type"::DATE);

                            Validate("Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field("Date Part"; "Date Part")
                {
                    Caption = 'Part';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the part of date which will be extracted.';
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionExtractDatePart2: Record "Action Extract Date Part");
    begin
        ActionExtractDatePart := ActionExtractDatePart2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionExtractDatePart."Case ID");
        SetRange("Script ID", ActionExtractDatePart."Script ID");
        SetRange(ID, ActionExtractDatePart.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionExtractDatePart."Case ID", ActionExtractDatePart."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionExtractDatePart.TestField("Case ID");
        ActionExtractDatePart.TestField("Script ID");
        ActionExtractDatePart.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        VariableValue := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Value Type",
            Value,
            "Lookup ID",
            "Symbol Data Type"::DATE);
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
        ActionExtractDatePart: Record "Action Extract Date Part";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableValue: Text;
        VariableName2: Text[30];
}