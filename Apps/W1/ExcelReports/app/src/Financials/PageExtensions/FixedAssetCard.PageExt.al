pageextension 4022 "Fixed Asset Card" extends "Fixed Asset Card"
{
    actions
    {
        addfirst(reporting)
        {
            action("Fixed Asset Details - Excel")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Details';
                Image = View;
                RunObject = Report "EXR Fixed Asset Details Excel";
                ToolTip = 'View detailed information about the fixed asset ledger entries that have been posted to a specified depreciation book for each fixed asset.';
            }
        }
    }
}