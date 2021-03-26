page 20261 "Tax Components"
{
    Caption = 'Tax Components';
    PageType = List;
    RefreshOnActivate = true;
    AutoSplitKey = true;
    SourceTable = "Tax Component";
    layout
    {
        area(Content)
        {
            repeater(Group1)
            {
                field(Name; Name)
                {
                    ToolTip = 'Specifies the name of tax component.';
                    ApplicationArea = Basic, Suite;
                }
                field("Rounding Precision"; "Rounding Precision")
                {
                    ToolTip = 'Specifies the rounding precision of tax component.';
                    ApplicationArea = Basic, Suite;
                }
                field(Direction; Direction)
                {
                    ToolTip = 'Specifies the direction of rounding of tax component.';
                    ApplicationArea = Basic, Suite;
                }
                field("Skip Posting"; "Skip Posting")
                {
                    ToolTip = 'Specifies whether the component will be skipped from posting to GL for a tax use case.';
                    Caption = 'Skip G/L Posting';
                    ApplicationArea = Basic, Suite;
                }
                field("Visible on Interface"; "Visible on Interface")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether component will be visible on tax information factbox.';
                }
                field("Component Type"; "Component Type")
                {
                    ToolTip = 'Specifies the type of component whether it is a normal component which will be computed on use cases or a formula component which is common to all use cases.';
                    Caption = 'Component Type';
                    ApplicationArea = Basic, Suite;
                }
                field(Formula; FormulaText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Formula';
                    ToolTip = 'Specifies the calculation formula of component.';
                    Editable = false;
                    StyleExpr = true;
                    Style = Subordinate;
                    trigger OnAssistEdit()
                    var
                        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
                    begin
                        TestRecord();
                        TestField("Component Type", "Component Type"::Formula);

                        if IsNullGuid("Formula ID") then begin
                            "Formula ID" := TaxTypeObjHelper.CreateComponentFormula("Tax Type", ID);
                            Commit();
                        end;
                        TaxTypeObjHelper.OpenComponentFormulaDialog("Formula ID");
                        FormatLine();
                    end;
                }
            }
        }
    }
    local procedure TestRecord()
    begin
        TestField("Tax Type");
        TestField(ID);
        TestField(Name);
    end;

    local procedure FormatLine()
    begin
        FormulaText := FormulaLbl;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := Type::Decimal;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    var
        FormulaText: Text;
        FormulaLbl: Label 'Click here to check the component formula';
}