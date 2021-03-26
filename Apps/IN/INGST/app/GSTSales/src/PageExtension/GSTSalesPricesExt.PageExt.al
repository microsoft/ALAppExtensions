pageextension 18152 "GST Sales Prices Ext" extends "Sales Prices"
{
    layout
    {
        addafter("Price Includes VAT")
        {
            field("Price Inclusive of Tax"; Rec."Price Inclusive of Tax")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if prices are Inclusive of tax on the line.';
            }
        }
    }
}