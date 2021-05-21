page 20284 "Tax Component Expr. Dialog"
{
    Caption = 'Component Expression';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    PopulateAllFields = true;
    SourceTable = "Tax Component Expression";
    layout
    {
        area(Content)
        {
            group(Group)
            {
                field(Expression; Expression)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the numeric expression.';
                }
            }

            part("Component Expr. Subform"; "Tax Component Expr. Subform")
            {
                Caption = 'Tokens';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Case ID" = Field("Case ID"), "Component Expr. ID" = Field(ID);
            }
        }
    }

    procedure SetCurrentRecord(var TaxComponentExpression2: Record "Tax Component Expression");
    begin
        TaxComponentExpression := TaxComponentExpression2;
        UseCase.Get(TaxComponentExpression."Case ID");
        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", TaxComponentExpression."Case ID");
        SetRange(ID, TaxComponentExpression.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(TaxComponentExpression."Case ID", EmptyGuid);
    end;

    local procedure TestRecord();
    begin
        TaxComponentExpression.TestField("Case ID");
        TaxComponentExpression.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Component, "Component ID");
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
        TaxComponentExpression: Record "Tax Component Expression";
        UseCase: Record "Tax Use Case";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableName: Text;
        EmptyGuid: Guid;
}