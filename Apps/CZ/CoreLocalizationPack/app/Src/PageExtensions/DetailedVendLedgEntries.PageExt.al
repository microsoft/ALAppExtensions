pageextension 31014 "Detailed Vend.Ledg.Entries CZL" extends "Detailed Vendor Ledg. Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Vendor Posting Group CZL"; Rec."Vendor Posting Group CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vendor''s market type to link business transactions made for the vendor with the appropriate account in the general ledger.';
            }
        }
    }
}