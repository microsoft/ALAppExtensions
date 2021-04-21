pageextension 31013 "Detailed Cust.Ledg.Entries CZL" extends "Detailed Cust. Ledg. Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Customer Posting Group CZL"; Rec."Customer Posting Group CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the customer''s market type to link business transactions to.';
            }
        }
    }
}