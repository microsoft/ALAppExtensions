pageextension 31250 "Inventory Setup CZA" extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("Use GPPG from SKU CZA"; Rec."Use GPPG from SKU CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the General Product Posting Group from the Stock keeping Unit is transferred to the documents.';
            }
            field("Skip Update SKU on Posting CZA"; Rec."Skip Update SKU on Posting CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies skiping Update SKU on Posting';
            }
            field("Exact Cost Revers. Mandat. CZA"; Rec."Exact Cost Revers. Mandat. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that a storno transaction cannot be posted unless the Applies-from Entry field on the item journal line specifies an entry.';
            }
        }
    }
}
