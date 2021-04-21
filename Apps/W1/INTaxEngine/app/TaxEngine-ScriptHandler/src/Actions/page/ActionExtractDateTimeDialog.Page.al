page 20162 "Action Extract DateTime Dialog"
{
    Caption = 'Extract Date Part';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Extract DateTime Part";
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
                        ScriptSymbolsMgmt.SearchSymbol(
                            "Symbol Type"::Variable,
                            "Variable ID",
                            VariableName2);

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
                field("Date Lookup"; VariableValue)
                {
                    Caption = 'Date Time';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies  whether Date or Time will be extracted.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID",
                            VariableValue,
                            "Symbol Data Type"::DATETIME)
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
                field("Date/Time Part"; "Part Type")
                {
                    Caption = 'Part';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies  whether part that will be extracted from Date Time value.';
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionExtractDateTimePart2: Record "Action Extract DateTime Part");
    begin
        ActionExtractDateTimePart := ActionExtractDateTimePart2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionExtractDateTimePart."Case ID");
        SetRange("Script ID", ActionExtractDateTimePart."Script ID");
        SetRange(ID, ActionExtractDateTimePart.ID);
        FilterGroup := 0;

        ScriptSymbolsMgmt.SetContext(ActionExtractDateTimePart."Case ID", ActionExtractDateTimePart."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionExtractDateTimePart.TestField("Case ID");
        ActionExtractDateTimePart.TestField("Script ID");
        ActionExtractDateTimePart.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        VariableValue := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Value Type",
            Value,
            "Lookup ID",
            "Symbol Data Type"::DATETIME);
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
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableValue: Text;
        VariableName2: Text[30];
}