pageextension 31178 "Posted Invt. Receipts CZL" extends "Posted Invt. Receipts"
{
    layout
    {
        addlast(Control1)
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