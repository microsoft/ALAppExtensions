namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
page 22208 "Reviewed G/L Entries"
{
    Caption = 'Reviewed G/L Entries';
    PageType = List;
    DataCaptionExpression = GetCaption();
    ApplicationArea = Basic, Suite;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    Permissions = tabledata "G/L Entry" = r;
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
        CaptionLbl: Label '%1 %2', Comment = '%1 is the G/L Account No. and %2 is the G/L Account Name';

    trigger OnAfterGetRecord()
    begin
        GLEntry.Get(Rec."G/L Entry No.");
    end;

    local procedure GetCaption(): Text[250]
    var
        GLAccount: record "G/L Account";
    begin
        if not GLAccount.Get(Rec."G/L Account No.") then
            if Rec.GetFilter(Rec."G/L Account No.") <> '' then
                GLAccount.Get(Rec.GetRangeMin(Rec."G/L Account No."));
        exit(StrSubstNo(CaptionLbl, GLAccount."No.", GLAccount.Name));
    end;
}