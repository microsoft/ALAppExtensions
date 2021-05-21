pageextension 31176 "Posted Invt. Shipments CZL" extends "Posted Invt. Shipments"
{
    layout
    {
        addlast(Control1)
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the template for item movement.';
                Editable = false;
            }
        }
    }
}