page 20178 "Action Round Number Dialog"
{
    Caption = 'Round Number';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Round Number";
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
                field(NumberLookupValue; NumberLookupValue2)
                {
                    Caption = 'Number';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Number which will be rounded.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Number Value Type",
                            "Number Value",
                            "Number Lookup ID",
                            NumberLookupValue2,
                            "Symbol Data Type"::NUMBER)
                        then
                            Validate("Number Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Number Value Type",
                            "Number Value",
                            "Number Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Number Lookup ID",
                                "Symbol Data Type"::NUMBER);
                            Validate("Number Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field(PrecisionLookupValue2; PrecisionLookupValue)
                {
                    Caption = 'Precision';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the precision of rounding.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Precision Value Type",
                            "Precision Value",
                            "Precision Lookup ID",
                            PrecisionLookupValue,
                            "Symbol Data Type"::NUMBER)
                        then
                            Validate("Precision Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Precision Value Type",
                            "Precision Value",
                            "Precision Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Precision Lookup ID",
                                "Symbol Data Type"::NUMBER);

                            Validate("Precision Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field(Direction; Direction)
                {
                    Caption = 'Direction';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the direction of rounding.';
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionRoundNumber2: Record "Action Round Number");
    begin
        ActionRoundNumber := ActionRoundNumber2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionRoundNumber."Case ID");
        SetRange("Script ID", ActionRoundNumber."Script ID");
        SetRange(ID, ActionRoundNumber.ID);
        FilterGroup := 0;

        ScriptSymbolsMgmt.SetContext(ActionRoundNumber."Case ID", ActionRoundNumber."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionRoundNumber.TestField("Case ID");
        ActionRoundNumber.TestField("Script ID");
        ActionRoundNumber.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        NumberLookupValue2 := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Number Value Type",
            "Number Value",
            "Number Lookup ID",
            "Symbol Data Type"::NUMBER);

        PrecisionLookupValue := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Precision Value Type",
            "Precision Value",
            "Precision Lookup ID",
            "Symbol Data Type"::NUMBER);

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
        ActionRoundNumber: Record "Action Round Number";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        NumberLookupValue2: Text;
        PrecisionLookupValue: Text;
        VariableName2: Text[30];
}