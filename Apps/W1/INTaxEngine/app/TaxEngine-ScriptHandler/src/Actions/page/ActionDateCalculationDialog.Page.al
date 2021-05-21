page 20159 "Action Date Calculation Dialog"
{
    Caption = 'Date Calculation Dialog';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Date Calculation";
    layout
    {
        area(Content)
        {
            group(General)
            {
                field(VariableName; VariableName2)
                {
                    Caption = 'Output To Variable';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the variable name which will store the output.';
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SearchSymbolOfType(
                            "Symbol Type"::Variable,
                            "Symbol Data Type"::DATE,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::DATE,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;
                }
                field(Date; DateVariable)
                {
                    Caption = 'Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Date variable which will store the value.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Date Value Type",
                            "Date Value",
                            "Date Lookup ID",
                            DateVariable,
                            "Symbol Data Type"::DATE)
                        then
                            Validate("Date Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Date Value Type",
                            "Date Value",
                            "Date Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Date Lookup ID",
                                "Symbol Data Type"::DATE);

                            Validate("Date Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field("Arithmetic operators"; "Arithmetic operators")
                {
                    Caption = 'Operator';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Artithmetic operation for calculation.';
                }
                field(Number; NumberVariable)
                {
                    Caption = 'Number';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Number that will added or subtracted on date.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Number Value Type",
                            "Number Value",
                            "Number Lookup ID",
                            NumberVariable,
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
                field(Duration; Duration)
                {
                    Caption = 'Period';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the period that will added or subtracted on date.';
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionDateCalculation2: Record "Action Date Calculation");
    begin
        ActionDateCalculation := ActionDateCalculation2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionDateCalculation."Case ID");
        SetRange("Script ID", ActionDateCalculation."Script ID");
        SetRange(ID, ActionDateCalculation.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionDateCalculation."Case ID", ActionDateCalculation."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionDateCalculation.TestField("Case ID");
        ActionDateCalculation.TestField("Script ID");
        ActionDateCalculation.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        DateVariable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Date Value Type",
            "Date Value",
            "Date Lookup ID",
            "Symbol Data Type"::DATE);

        NumberVariable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Number Value Type",
            "Number Value",
            "Number Lookup ID",
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
        ActionDateCalculation: Record "Action Date Calculation";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        DateVariable: Text;
        NumberVariable: Text;
        VariableName2: Text[30];
}