#pragma warning disable AA0247
pageextension 14113 WarehouseManagerRCExt extends "Warehouse Manager Role Center"
{
    actions
    {
        addafter("Transfer Routes")
        {
            action("CD Number Formats")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'CD Number Formats';
                RunObject = page "CD Number Formats";
            }
        }
    }
}
