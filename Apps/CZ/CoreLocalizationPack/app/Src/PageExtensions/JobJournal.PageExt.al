pageextension 11714 "Job Journal CZL" extends "Job Journal"
{
    layout
    {
        addafter("Document Date")
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the template for item movement.';
            }
        }
    }
}
