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
                field("Posting Date"; GLEntry."Posting Date")
                {
                    ToolTip = 'Specifies the date when the G/L entry was posted.';
                }
                field("Document Type"; GLEntry."Document Type")
                {
                    ToolTip = 'Specifies the type of document associated with the G/L entry.';
                }
                field("Document No."; GLEntry."Document No.")
                {
                    ToolTip = 'Specifies the document number associated with the G/L entry.';
                }
                field(Description; GLEntry.Description)
                {
                    ToolTip = 'Specifies the description of the G/L entry.';
                }
                field(Amount; GLEntry.Amount)
                {
                    ToolTip = 'Specifies the amount of the G/L entry.';
                }
                field("Reviewed Identifier"; Rec."Reviewed Identifier")
                {
                }
                field("Reviewed By"; Rec."Reviewed By")
                {
                }
                field("Reviewed Amount"; Rec."Reviewed Amount")
                {
                }
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