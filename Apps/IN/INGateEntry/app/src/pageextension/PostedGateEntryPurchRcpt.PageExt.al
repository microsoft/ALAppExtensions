pageextension 18608 "Posted Gate Entry Purch. Rcpt." extends "Posted Purchase Receipt"
{
    layout
    {
        addlast(General)
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
        addlast("&Receipt")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Posted Gate Attachment List";
                RunPageLink = "Entry Type" = const(Inward), "Receipt No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}