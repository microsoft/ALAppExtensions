pageextension 31009 "Stockkeeping Unit Card CZL" extends "Stockkeeping Unit Card"
{
    layout
    {
        addlast(General)
        {
            field("Gen. Prod. Posting Group CZL"; Rec."Gen. Prod. Posting Group CZL")
            {
                ApplicationArea = Planning;
                ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
            }
        }
    }
}
