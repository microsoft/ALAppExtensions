reportextension 31006 "Cash Flow Date List CZZ" extends "Cash Flow Date List CZL"
{
    dataset
    {
        modify(EditionPeriod)
        {
            trigger OnAfterAfterGetRecord()
            begin
                SalesAdvanceValue := CashFlow.CalcSourceTypeAmount(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ");
                PurchaseAdvanceValue := CashFlow.CalcSourceTypeAmount(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ");
            end;
        }
    }
}
