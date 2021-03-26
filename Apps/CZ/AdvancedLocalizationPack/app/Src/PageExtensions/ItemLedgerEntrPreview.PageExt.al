pageextension 31258 "Item Ledger Entr. Preview CZA" extends "Item Ledger Entries Preview"
{
    layout
    {
        addafter("Source No.")
        {
            field("Invoice-to Source No. CZA"; Rec."Invoice-to Source No. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies where the entry originated';
                Visible = false;
            }
            field("Delivery-to Source No. CZA"; Rec."Delivery-to Source No. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies where the entry originated';
                Visible = false;
            }
        }
    }
}
