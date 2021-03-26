pageextension 18685 "G/L Registers" extends "G/L Registers"
{
    actions
    {
        addafter("Item Ledger Relation")
        {
            action("TDS Entries")
            {
                ApplicationArea = Basic, Suite;
                Image = CollectedTax;
                ToolTip = 'View the TDS ledger entries that resulted in the current register entry.';

                trigger OnAction()
                var
                    TDSManagement: Codeunit "TDS Entity Management";
                begin
                    TDSManagement.OpenTDSEntries(Rec."From Entry No.", Rec."To Entry No.");
                end;
            }
        }
    }
}