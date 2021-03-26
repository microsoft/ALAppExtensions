pageextension 18613 "Posted Gate Entry Whse Rcpt" extends "Posted Whse. Receipt"
{
    actions
    {
        addlast("&Receipt")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = Page "Posted Gate Attachment List";
                RunPageLink = "Entry Type" = const(Inward), "Warehouse Recpt. No." = field("Whse. Receipt No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}