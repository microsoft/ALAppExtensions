namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Ledger;
page 22208 "Reviewed G/L Entries"
{
    Caption = 'Reviewed G/L Entries';
    PageType = List;
    ApplicationArea = Basic, Suite;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "G/L Entry Review Setup" = ri;
    SourceTable = "G/L Entry Review Log";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Posting Date"; GLEntry."Posting Date") { }
                field("Document Type"; GLEntry."Document Type") { }
                field("Document No."; GLEntry."Document No.") { }
                field(Description; GLEntry.Description) { }
                field(Amount; GLEntry.Amount) { }
                field("Reviewed Identifier"; Rec."Reviewed Identifier") { }
                field("Reviewed By"; Rec."Reviewed By") { }
                field("Reviewed Amount"; Rec."Reviewed Amount") { }
            }
        }
    }

    var
        GLEntry: Record "G/L Entry";

    trigger OnAfterGetRecord()
    begin
        GLEntry.Get(Rec."G/L Entry No.");
    end;
}