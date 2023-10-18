pageextension 31171 "Invt. Shipment CZL" extends "Invt. Shipment"
{
    layout
    {
        addbefore("Gen. Bus. Posting Group")
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the template for item movement.';
            }
        }
    }
}