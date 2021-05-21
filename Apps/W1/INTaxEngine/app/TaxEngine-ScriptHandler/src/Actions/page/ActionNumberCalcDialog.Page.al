page 20174 "Action Number Calc. Dialog"
{
    Caption = 'Number Calculation Dialog';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Number Calculation";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(OutputToVariableName; OutputToVariableName2)
                {
                    Caption = 'Output Variable';
                    ToolTip = 'Specifies the variable which will store the output.';
                    ApplicationArea = Basic, Suite;
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SearchSymbolOfType(
                            "Symbol Type"::Variable,
                            "Symbol Data Type"::NUMBER,
                            "Variable ID",
                            OutputToVariableName2);
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::NUMBER,
                            "Variable ID",
                            OutputToVariableName2);
                    end;
                }
                field(LHSValue; LHSValue2)
                {
                    Caption = 'Value';
                    ToolTip = 'Specifies the value of LHS.';
                    ApplicationArea = Basic, Suite;
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "LHS Type",
                            "LHS Value",
                            "LHS Lookup ID",
                            LHSValue2,
                            "Symbol Data Type"::NUMBER)
                        then
                            Validate("LHS Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "LHS Type",
                            "LHS Value",
                            "LHS Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "LHS Lookup ID",
                                "Symbol Data Type"::NUMBER);
                            Validate("LHS Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field("Arithmetic operators"; "Arithmetic Operator")
                {
                    Caption = 'Operator';
                    ToolTip = 'Specifies the value of arithmetic operator used in calculation';
                    ApplicationArea = Basic, Suite;
                }
                field(RHSValue2; RHSValue)
                {
                    Caption = 'Value';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of RHS.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "RHS Type",
                            "RHS Value",
                            "RHS Lookup ID",
                            RHSValue,
                            "Symbol Data Type"::NUMBER)
                        then
                            Validate("RHS Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "RHS Type",
                            "RHS Value",
                            "RHS Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "RHS Lookup ID",
                                "Symbol Data Type"::NUMBER);
                            Validate("RHS Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    procedure SetCurrentRecord(var RuleCalculation2: Record "Action Number Calculation");
    begin
        RuleCalculation := RuleCalculation2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", RuleCalculation."Case ID");
        SetRange("Script ID", RuleCalculation."Script ID");
        SetRange(ID, RuleCalculation.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(RuleCalculation."Case ID", RuleCalculation."Script ID");
    end;


    local procedure TestRecord();
    begin
        RuleCalculation.TestField("Case ID");
        RuleCalculation.TestField("Script ID");
        RuleCalculation.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        LHSValue2 := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "LHS Type",
            "LHS Value",
            "LHS Lookup ID",
            "Symbol Data Type"::NUMBER);

        RHSValue := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "RHS Type",
            "RHS Value",
            "RHS Lookup ID",
            "Symbol Data Type"::NUMBER);

        OutputToVariableName2 := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, "Variable ID");
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
        RuleCalculation: Record "Action Number Calculation";
        LookupSerialization: Codeunit "Lookup Serialization";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LHSValue2: Text;
        RHSValue: Text;
        OutputToVariableName2: Text[30];
}