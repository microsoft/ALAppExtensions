page 20175 "Action Number Expr. Dialog"
{
    Caption = 'Numeric Expression';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    PopulateAllFields = true;
    SourceTable = "Action Number Expression";
    layout
    {
        area(Content)
        {
            group(Group)
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
                field(Expression; Expression)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the numeric expression.';
                }
            }
            part("Number Expr. Subform"; "Action Number Expr. Subform")
            {
                Caption = 'Tokens';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Case ID" = field("Case ID"), "Numeric Expr. ID" = field(ID);
            }
        }
    }

    procedure SetCurrentRecord(var ActionNumberExpression2: Record "Action Number Expression");
    begin
        ActionNumberExpression := ActionNumberExpression2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionNumberExpression."Case ID");
        SetRange("Script ID", ActionNumberExpression."Script ID");
        SetRange(ID, ActionNumberExpression.ID);
        FilterGroup := 0;

        ScriptSymbolsMgmt.SetContext(ActionNumberExpression."Case ID", ActionNumberExpression."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionNumberExpression.TestField("Case ID");
        ActionNumberExpression.TestField("Script ID");
        ActionNumberExpression.TestField(ID);
    end;

    local procedure FormatLine();
    begin
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
        ActionNumberExpression: Record "Action Number Expression";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableName2: Text[30];
}