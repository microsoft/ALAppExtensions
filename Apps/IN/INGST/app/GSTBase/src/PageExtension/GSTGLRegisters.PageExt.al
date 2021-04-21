pageextension 18017 "GST G/L Registers" extends "G/L Registers"
{
    actions
    {
        addafter("Item Ledger Relation")
        {
            action("GST Ledger Entries")
            {
                ApplicationArea = Basic, Suite;
                Image = CollectedTax;
                ToolTip = ' View the GST Ledger Entries that resulted in the current register entry.';

                trigger OnAction()
                var
                    GSTBaseValidation: Codeunit "GST Base Validation";
                begin
                    GSTBaseValidation.OpenGSTEntries(Rec."From Entry No.", Rec."To Entry No.");
                end;
            }
            action("Detailed GST Ledger Entries")
            {
                ApplicationArea = Basic, Suite;
                Image = CollectedTax;
                ToolTip = 'View the GST Ledger entries in detail line wise that resulted in the current register entry.';

                trigger OnAction()
                var
                    GSTBaseValidation: Codeunit "GST Base Validation";
                begin
                    GSTBaseValidation.OpenDetailedGSTEntries(Rec."From Entry No.", Rec."To Entry No.");
                end;
            }
        }
    }
}