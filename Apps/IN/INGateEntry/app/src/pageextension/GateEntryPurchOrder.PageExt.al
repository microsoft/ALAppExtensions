pageextension 18603 "Gate Entry Purch. Order" extends "Purchase Order"
{
    actions
    {
        addlast("F&unctions")
        {
            action("Get Gate Entry Lines")
            {
                ApplicationArea = Basic, Suite;
                Image = GetLines;
                ToolTip = 'View available gate entry lines for attachment.';
                trigger OnAction()
                var
                    GateEntryHandler: Codeunit "Gate Entry Handler";
                begin
                    GateEntryHandler.GetPurchaseGateEntryLines(Rec);
                end;
            }
        }
        addlast("F&unctions")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Gate Entry Attachment List";
                RunPageLink = "Source No." = field("No."), "Source Type" = const("Purchase Order"), "Entry Type" = const(Inward);
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}