pageextension 11734 "Posted Sales Invoices CZL" extends "Posted Sales Invoices"
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
