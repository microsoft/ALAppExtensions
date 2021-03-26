pageextension 18610 "Posted Gate Entry Return Rcpt." extends "Posted Return Receipt"
{
    actions
    {
        addlast("&Return Rcpt.")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = Page "Posted Gate Attachment List";
                RunPageLink = "Entry Type" = const(Inward), "Receipt No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}