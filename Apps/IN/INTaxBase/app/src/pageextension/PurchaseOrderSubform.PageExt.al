pageextension 18552 "Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        modify(Type)
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Direct Unit Cost")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Line Amount")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Line Discount %")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Line Discount Amount")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Invoice Discount Amount")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
    }

    local procedure UpdateTaxAmount()
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CurrPage.SaveRecord();
        CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
    end;
}