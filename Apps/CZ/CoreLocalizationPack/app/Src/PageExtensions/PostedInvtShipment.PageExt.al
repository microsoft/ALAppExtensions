pageextension 31175 "Posted Invt. Shipment CZL" extends "Posted Invt. Shipment"
{
    layout
    {
        addbefore("Gen. Bus. Posting Group")
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the template for item movement.';
                Editable = false;
            }
        }
    }
}