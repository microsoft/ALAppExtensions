pageextension 11745 "Posted Purchase Invoices CZL" extends "Posted Purchase Invoices"
{
    layout
    {
        addafter("Posting Date")
        {
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
                Visible = false;
            }
        }
    }
}
