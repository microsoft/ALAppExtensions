page 20263 "Tax Component Formula Dialog"
{
    Caption = 'Component Expression';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    PopulateAllFields = true;
    SourceTable = "Tax Component Formula";
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

            part("Component Expr. Subform"; "Tax Component Formula Subform")
            {
                Caption = 'Tokens';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Tax Type" = field("Tax Type"), "Formula Expr. ID" = field(ID);
            }
        }
    }

    procedure SetCurrentRecord(var TaxComponentFormula2: Record "Tax Component Formula");
    begin
        TaxComponentFormula := TaxComponentFormula2;
        TestRecord();

        FilterGroup := 2;
        SetRange("Tax Type", TaxComponentFormula."Tax Type");
        SetRange(ID, TaxComponentFormula.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(TaxComponentFormula."Tax Type", EmptyGuid, EmptyGuid);
    end;

    local procedure TestRecord();
    begin
        TaxComponentFormula.TestField("Tax Type");
        TaxComponentFormula.TestField(ID);
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
        TaxComponentFormula: Record "Tax Component Formula";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableName: Text;
        EmptyGuid: Guid;
}