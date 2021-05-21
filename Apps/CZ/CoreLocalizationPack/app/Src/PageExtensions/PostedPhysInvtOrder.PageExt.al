pageextension 31003 "Posted Phys. Invt. Order CZL" extends "Posted Phys. Invt. Order"
{
    actions
    {
        addlast(reporting)
        {
            action(PhysInventoryDocumentCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Counting Document';
                Image = Print;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Print physical inventory counting document.';

                trigger OnAction()
                var
                    PhysInventoryLedgerEntry: Record "Phys. Inventory Ledger Entry";
                begin
                    PhysInventoryLedgerEntry.SetRange("Document No.", Rec."No.");
                    PhysInventoryLedgerEntry.SetRange("Posting Date", Rec."Posting Date");
                    Report.Run(Report::"Phys. Inventory Document CZL", true, false, PhysInventoryLedgerEntry);
                end;
            }
        }
    }
}
