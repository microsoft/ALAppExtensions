pageextension 31172 "Invt. Shipments CZL" extends "Invt. Shipments"
{
    layout
    {
        addlast(Control1)
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the template for item movement.';
            }
        }
    }
}