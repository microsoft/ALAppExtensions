// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

using Microsoft.Finance.GeneralLedger.Reversal;
using Microsoft.Foundation.Navigate;

page 18769 "Provisional Entries"
{
    Caption = 'Provisional Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Provisional Entry";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type on the ledger entry.';
                }
                field("Posted Document No."; Rec."Posted Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number which identifies the posted transaction.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the ledger entry.';
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
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the posted entry is reversed.';
                }
                field("Original Invoice Posted"; Rec."Original Invoice Posted")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original invoice number.';
                }
                field("Applied Invoice No."; Rec."Applied Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied invoice number.';
                }
                field("Original Invoice Reversed"; Rec."Original Invoice Reversed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the original invoice is reversed.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who created the document.';
                }
                field("Applied by Vendor Ledger Entry"; Rec."Applied by Vendor Ledger Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied vendor ledger entry number.';
                }
                field("Reversed After TDS Paid"; Rec."Reversed After TDS Paid")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the entry is reversed after TDS payment.';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether this is an open entry or not.';
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(ReverseTransaction)
            {
                Caption = 'Reverse Transaction';
                Ellipsis = true;
                Image = ReverseRegister;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Reverse a posted provisional ledger entry.';
                Scope = Repeater;

                trigger OnAction()
                var
                    ReversalEntry: Record "Reversal Entry";
                    ProvisionalEntry: Record "Provisional Entry";
                    ProvEntReversalMgt: Codeunit "Provisional Entry Reversal Mgt";
                    MultiLinesErr: Label 'You cannot select multiple lines.';
                begin
                    ProvEntReversalMgt.SetReverseProvEntWithoutTDS(false);
                    CurrPage.SetSelectionFilter(ProvisionalEntry);
                    if ProvisionalEntry.Count > 1 then
                        Error(MultiLinesErr);
                    Clear(ReversalEntry);
                    if Rec.Reversed then
                        ReversalEntry.AlreadyReversedEntry(CopyStr(Rec.TableCaption, 1, 50), Rec."Entry No.");
                    if Rec."Journal Batch Name" = '' then
                        ReversalEntry.TestFieldError();
                    Rec.TestField("Transaction No.");
                    ReversalEntry.ReverseTransaction(Rec."Transaction No.");
                end;
            }
            action("Reverse Without TDS")
            {
                Caption = 'Reverse Without TDS';
                Image = Undo;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Reverse a posted provisional ledger entry without TDS entry.';

                trigger OnAction()
                var
                    ReversalEntry: Record "Reversal Entry";
                    ProvisionalEntry: Record "Provisional Entry";
                    ProvisionalEntryHandler: Codeunit "Provisional Entry Handler";
                    ProvEntReversalMgt: Codeunit "Provisional Entry Reversal Mgt";
                    MultiLinesErr: Label 'You cannot select multiple lines.';
                begin
                    ProvEntReversalMgt.SetReverseProvEntWithoutTDS(false);
                    CurrPage.SetSelectionFilter(ProvisionalEntry);
                    if ProvisionalEntry.Count > 1 then
                        Error(MultiLinesErr);
                    if Rec.Reversed then
                        ReversalEntry.AlreadyReversedEntry(CopyStr(Rec.TableCaption, 1, 50), Rec."Entry No.");
                    ProvisionalEntryHandler.ReverseProvisionalEntries(Rec."Transaction No.");
                end;
            }
            action(Navigate)
            {
                Caption = '&Navigate';
                Image = Navigate;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Find all entries and documents that exist for the document and posting date on the selected entry or document.';
                Scope = Repeater;

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
}
