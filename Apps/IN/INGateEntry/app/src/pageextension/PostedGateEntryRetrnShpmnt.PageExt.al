pageextension 18609 "Posted Gate Entry Retrn Shpmnt" extends "Posted Return Shipment"
{
    layout
    {
        addlast(Shipping)
        {
            field("Vehicle No."; Rec."Vehicle No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vehicle number.';
            }
            field("Vehicle Type"; Rec."Vehicle Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of vehicle.';
            }
        }
    }

    actions
    {
        addlast("&Return Shpt.")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Outward Gate Entry Line List";
                RunPageLink = "Entry Type" = const(Outward), "Source Type" = const("Purchase Return Shipment"), "Source No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}