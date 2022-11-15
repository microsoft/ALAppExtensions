pageextension 31198 "Cash Flow Forecast Stat. CZZ" extends "Cash Flow Forecast Statistics"
{
    layout
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify(SalesAdvances)
        {
            Visible = false;
        }
        modify(PurchaseAdvances)
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
        addafter(Tax)
        {
            field(SalesAdvancesCZZ; Rec.CalcSourceTypeAmount(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ"))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Advances';
                ToolTip = 'Specifies an amount of sales advances';

                trigger OnDrillDown()
                begin
                    Rec.DrillDownSourceTypeEntries(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ");
                end;
            }
            field(PurchaseAdvancesCZZ; Rec.CalcSourceTypeAmount(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ"))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Advances';
                ToolTip = 'Specifies an amount of purchase advances';

                trigger OnDrillDown()
                begin
                    Rec.DrillDownSourceTypeEntries(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ");
                end;
            }
        }
    }
}
