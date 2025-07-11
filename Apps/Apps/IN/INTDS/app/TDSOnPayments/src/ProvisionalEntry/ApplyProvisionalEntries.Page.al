// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

using Microsoft.Foundation.Navigate;
using Microsoft.Finance.GeneralLedger.Journal;

page 18770 "Apply Provisional Entries"
{
    Caption = 'Apply Provisional Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Provisional Entry";
    SourceTableView = where(Open = const(true));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posted Document No."; Rec."Posted Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number which identifies the posted transaction.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("Party Type"; Rec."Party Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the party type of the transaction.';
                }
                field("Party Code"; Rec."Party Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant party code of the transaction.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account where the entry will be posted.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the entry will be posted.';
                }
                field("TDS Section Code"; Rec."TDS Section Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS Section code.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount of the transaction.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code for the entry.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account where the balancing entry will be posted.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the balancing entry will be posted.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of location where the entry is posted to.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who created the document.';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether this is an open entry or not.';
                }
                field("Purchase Invoice No."; Rec."Purchase Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the invoice number to be applied.';
                }
                field("Applied User ID"; Rec."Applied User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user to be applied.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(Apply)
            {
                Caption = 'Apply';
                Image = ApplyEntries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the entries for application.';

                trigger OnAction()
                begin
                    CheckMultiLineEntry(ProvisionalEntry);
                    Rec.Apply(GenJournalLine);
                end;
            }
            action(Unapply)
            {
                Caption = 'Unapply';
                Image = Undo;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the applied entries to be unapply';

                trigger OnAction()
                begin
                    CheckMultiLineEntry(ProvisionalEntry);
                    Rec.Unapply(GenJournalLine);
                end;
            }
            action(Navigate)
            {
                Caption = '&Navigate';
                Image = Navigate;
                ToolTip = 'View and navigate posted transactions.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Posted Document No.");
                    Navigate.Run();
                end;
            }
        }
    }

    var
        GenJournalLine: Record "Gen. Journal Line";
        ProvisionalEntry: Record "Provisional Entry";
        MultiLinesErr: Label 'You cannot select multiple lines.';

    procedure SetGenJnlLine(NewGenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine := NewGenJournalLine;
    end;

    local procedure CheckMultiLineEntry(ProvisionalEntry: Record "Provisional Entry")
    begin
        CurrPage.SetSelectionFilter(ProvisionalEntry);
        if ProvisionalEntry.Count() > 1 then
            Error(MultiLinesErr);
    end;
}
