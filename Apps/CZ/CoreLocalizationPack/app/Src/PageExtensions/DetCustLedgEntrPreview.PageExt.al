pageextension 31034 "Det.Cust.Ledg.Entr.Preview CZL" extends "Det. Cust. Ledg. Entr. Preview"
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