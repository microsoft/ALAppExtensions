#pragma warning disable AA0247
pageextension 14111 ItemTrackingCodeCardExt extends "Item Tracking Code Card"
{
    layout
    {
        AddAfter("Package Warehouse Tracking")
        {
            field("CD Location Setup Exists"; Rec."CD Location Setup Exists")
            {
                ApplicationArea = ItemTracking;
                ToolTip = 'Specifies if any customs declaration numbers exist for the item.';
            }
        }
    }

    actions
    {
        AddLast(navigation)
        {
            action("CD Location Setup")
            {
                ApplicationArea = Location;
                Caption = 'CD Location Setup';
                Image = Track;
                RunObject = Page "CD Location Setup";
                RunPageLink = "Item Tracking Code" = FIELD(Code);
                ToolTip = 'Set up custom declaration specific tracking for the location.';
            }
        }
    }
}
