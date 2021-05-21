pageextension 11783 "Depreciation Book Card CZL" extends "Depreciation Book Card"
{
    layout
    {
        addlast(General)
        {
            field("Mark Reclass. as Correct. CZL"; Rec."Mark Reclass. as Correct. CZL")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies to post reclassification as corrections.';
            }
        }
    }
}
