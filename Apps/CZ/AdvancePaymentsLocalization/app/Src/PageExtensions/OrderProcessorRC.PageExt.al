pageextension 31105 "Order Processor RC CZZ" extends "Order Processor Role Center"
{
    actions
    {
        addafter(SalesOrders)
        {
            action(SalesAdvLettersAfterOrdersCZZ)
            {
                Caption = 'Sales Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show sales advance letters.';
                RunObject = Page "Sales Advance Letters CZZ";
                RunPageView = where(Status = filter(New | "To Pay" | "To Use"));
            }
        }
        addafter("Sales Credit Memos")
        {
            action(SalesAdvLettersAfterCMCZZ)
            {
                Caption = 'Sales Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show sales advance letters.';
                RunObject = Page "Sales Advance Letters CZZ";
                RunPageView = where(Status = filter(New | "To Pay" | "To Use"));
            }
        }
        addafter("Purchase Credit Memos")
        {
            action(PurchAdvLettersCZZ)
            {
                Caption = 'Purchase Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show purchase advance letters.';
                RunObject = Page "Purch. Advance Letters CZZ";
                RunPageView = where(Status = filter(New | "To Pay" | "To Use"));
            }
        }
    }
}
