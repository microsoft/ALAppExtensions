pageextension 18614 "Posted Transfer Shipment" extends "Posted Transfer Shipment"
{
    actions
    {
        addlast("&Shipment")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Outward Gate Entry Line List";
                RunPageLink = "Entry Type" = const(Outward), "Source Type" = const("Transfer Shipment"), "Source No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}