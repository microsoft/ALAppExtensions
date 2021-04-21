page 20180 "Action String Expr. Dialog"
{
    Caption = 'String Expression';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    PopulateAllFields = true;
    SourceTable = "Action String Expression";
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
                field(Expression; Expression)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the String Expression.';
                }
            }
            part("String Expr. Subform"; "Action String Expr. Subform")
            {
                Caption = 'Tokens';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Script ID" = field("Script ID"), "String Expr. ID" = field(ID);
            }
        }
    }

    procedure SetCurrentRecord(var ActionStringExpression2: Record "Action String Expression");
    begin
        ActionStringExpression := ActionStringExpression2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionStringExpression."Case ID");
        SetRange("Script ID", ActionStringExpression."Script ID");
        SetRange(ID, ActionStringExpression.ID);
        FilterGroup := 0;

        ScriptSymbolsMgmt.SetContext(ActionStringExpression."Case ID", ActionStringExpression."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionStringExpression.TestField("Case ID");
        ActionStringExpression.TestField("Script ID");
        ActionStringExpression.TestField(ID);
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
        ActionStringExpression: Record "Action String Expression";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableName2: Text[30];
}