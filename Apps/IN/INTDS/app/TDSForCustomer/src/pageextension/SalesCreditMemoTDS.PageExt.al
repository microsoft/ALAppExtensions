pageextension 18670 "Sales Credit Memo TDS" extends "Sales Credit Memo"
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