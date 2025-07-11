#pragma warning disable AA0247
pageextension 14112 ItemTrackingCodesExt extends "Item Tracking Codes"
{
    layout
    {
        AddAfter("Package Specific Tracking")
        {
            field("CD Location Setup Exists"; Rec."CD Location Setup Exists")
            {
                ApplicationArea = ItemTracking;
                ToolTip = 'Specifies if any customs declaration numbers exist for the item.';
            }
        }
    }
}
