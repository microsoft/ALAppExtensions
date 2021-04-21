pageextension 18665 "Sales Order TDS" extends "Sales Order"
{
    layout
    {
        addlast("Tax Info")
        {
            field("TDS Certificate Receivable"; Rec."TDS Certificate Receivable")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Selected to allow calculating TDS for the customer.';
            }
        }
    }
}