pageextension 31173 "Invt. Receipt CZL" extends "Invt. Receipt"
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