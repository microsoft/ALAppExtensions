#pragma warning disable AA0247
pageextension 14110 FixedAssetCardExt extends "Fixed Asset Card"
{
    layout
    {
        addafter("Search Description")
        {
            field("CD Number"; Rec."CD Number")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the customs declaration number.';
            }
        }
    }
}
