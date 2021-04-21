pageextension 18612 "Posted Gate Entry Transfr Rcpt" extends "Posted Transfer Receipt"
{
    actions
    {
        addlast("&Receipt")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Posted Gate Attachment List";
                RunPageLink = "Source Type" = const("Transfer Receipt"), "Entry Type" = const(Inward), "Receipt No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}