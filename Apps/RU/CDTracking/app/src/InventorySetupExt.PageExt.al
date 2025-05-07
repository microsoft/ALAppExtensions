#pragma warning disable AA0247
pageextension 14115 InventorySetupExt extends "Inventory Setup"
{
    layout
    {
        AddLast(General)
        {
            field("Check CD Number Format"; Rec."Check CD Number Format")
            {
                ApplicationArea = ItemTracking;
                ToolTip = 'Specifies if customs declaration number format should be checked.';
            }
        }
    }
}
