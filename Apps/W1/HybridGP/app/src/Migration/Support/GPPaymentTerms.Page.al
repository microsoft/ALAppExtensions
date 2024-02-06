namespace Microsoft.DataMigration.GP;

page 40134 "GP Payment Terms"
{
    ApplicationArea = All;
    Caption = 'GP Payment Terms';
    PageType = Worksheet;
    SourceTable = "GP Payment Terms";
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(DateFormulaIsValid; DateFormulaIsValid)
                {
                    Caption = 'Valid Date Formula';
                    ToolTip = 'Indicates if the resulting date formula is valid.';
                    Editable = false;
                }
                field(CalculatedDateFormula; CalculatedDateFormulaTxt)
                {
                    Caption = 'Calculated Date Formula';
                    ToolTip = 'Calculated Date Formula';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = not DateFormulaIsValid;
                }
                field(PYMTRMID; Rec.PYMTRMID)
                {
                    ToolTip = 'Specifies the value of the Payment Terms ID field.';
                }
                field(DUETYPE; Rec.DUETYPE)
                {
                    ToolTip = 'Specifies the value of the Due Type field.';
                }
                field(DUEDTDS; Rec.DUEDTDS)
                {
                    ToolTip = 'Specifies the value of the Due Date/Days field.';
                }
                field(DISCTYPE; Rec.DISCTYPE)
                {
                    ToolTip = 'Specifies the value of the Discount Type field.';
                }
                field(DISCDTDS; Rec.DISCDTDS)
                {
                    ToolTip = 'Specifies the value of the Discount Date/Days field.';
                }
                field(DSCLCTYP; Rec.DSCLCTYP)
                {
                    ToolTip = 'Specifies the value of the Discount Calculate Type field.';
                }
                field(DSCPCTAM; Rec.DSCPCTAM)
                {
                    ToolTip = 'Specifies the value of the Discount Percent Amount field.';
                }
                field(TAX; Rec.TAX)
                {
                    ToolTip = 'Specifies the value of the Tax field.';
                }
                field(CBUVATMD; Rec.CBUVATMD)
                {
                    ToolTip = 'Specifies the value of the CB_Use_VAT_Mode field.';
                }
                field(USEGRPER; Rec.USEGRPER)
                {
                    ToolTip = 'Specifies the value of the Use Grace Periods field.';
                }
                field(CalculateDateFrom; Rec.CalculateDateFrom)
                {
                    ToolTip = 'Specifies the value of the Calculate Date From field.';
                }
                field(CalculateDateFromDays; Rec.CalculateDateFromDays)
                {
                    ToolTip = 'Specifies the value of the Calculate Date From Days field.';
                }
                field(DueMonth; Rec.DueMonth)
                {
                    ToolTip = 'Specifies the value of the Due Month field.';
                }
                field(DiscountMonth; Rec.DiscountMonth)
                {
                    ToolTip = 'Specifies the value of the Discount Month field.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateRecordStatus();
    end;


    trigger OnAfterGetCurrRecord()
    begin
        UpdateRecordStatus();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        UpdateRecordStatus();
        exit(true);
    end;

    local procedure UpdateRecordStatus()
    begin
        DateFormulaIsValid := Rec.GetCalculatedDateForumla(CalculatedDateFormulaTxt);
    end;

    var
        CalculatedDateFormulaTxt: Text[50];
        DateFormulaIsValid: Boolean;
}