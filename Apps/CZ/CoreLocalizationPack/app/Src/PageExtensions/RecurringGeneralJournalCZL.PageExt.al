// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.ReceivablesPayables;

pageextension 11725 "Recurring General Journal CZL" extends "Recurring General Journal"
{
    layout
    {
        modify("Account Type")
        {
            trigger OnAfterValidate()
            begin
                EnableApplyEntriesAction();
            end;
        }
        moveafter("Document No."; "External Document No.")
        addafter("Posting Date")
        {
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT date of the original document.';
                Visible = false;
            }
        }
        addafter("Account No.")
        {
            field("Posting Group CZL"; Rec."Posting Group")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the posting group that will be used in posting the journal line.The field is used only if the account type is either customer or vendor.';
                Visible = false;
            }
        }
        addbefore(Amount)
        {
            field("Correction CZL"; Rec.Correction)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the entry as a corrective entry. You can use the field if you need to post a corrective entry to an account.';
                Visible = false;
            }
        }
        addafter("Payment Terms Code")
        {
            field("Due Date CZL"; Rec."Due Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the due date on the entry.';
                Visible = false;
            }
        }
        addafter("Ship-to/Order Address Code")
        {
            field("Original Doc. Partner Type CZL"; Rec."Original Doc. Partner Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of partner (customer or vendor). It''s possible for VAT Control Report.';
            }
            field("Original Doc. Partner No. CZL"; Rec."Original Doc. Partner No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of partner (customer or vendor). It''s possible for VAT Control Report.';
            }
        }
    }

    actions
    {
        addfirst("P&osting")
        {
            action("Reconcile CZL")
            {
                ApplicationArea = Suite;
                Caption = 'Reconcile';
                Image = Reconcile;
                ShortcutKey = 'Ctrl+F11';
                ToolTip = 'Opens reconciliation page.';

                trigger OnAction()
                var
                    Reconciliation: Page Reconciliation;
                begin
                    Reconciliation.SetGenJnlLine(Rec);
                    Reconciliation.Run();
                end;
            }
        }
        addafter("P&osting")
        {
            group(Application)
            {
                Caption = 'Application';
                action("Apply Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Apply Entries';
                    Ellipsis = true;
                    Enabled = ApplyEntriesActionEnabled;
                    Image = ApplyEntries;
                    RunObject = Codeunit "Gen. Jnl.-Apply";
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Apply the payment amount on a journal line to a sales or purchase document that was already posted for a customer or vendor. This updates the amount on the posted document, and the document can either be partially paid, or closed as paid or refunded.';
                }
            }
        }
        addlast(Category_Process)
        {
            actionref("Apply Entries_Promoted CZL"; "Apply Entries")
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        EnableApplyEntriesAction();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        EnableApplyEntriesAction();
    end;

    var
        ApplyEntriesActionEnabled: Boolean;

    local procedure EnableApplyEntriesAction()
    begin
        ApplyEntriesActionEnabled :=
          (Rec."Account Type" in [Rec."Account Type"::Customer, Rec."Account Type"::Vendor, Rec."Account Type"::Employee]) or
          (Rec."Bal. Account Type" in [Rec."Bal. Account Type"::Customer, Rec."Bal. Account Type"::Vendor, Rec."Bal. Account Type"::Employee]);

        OnAfterEnableApplyEntriesAction(Rec, ApplyEntriesActionEnabled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEnableApplyEntriesAction(GenJournalLine: Record "Gen. Journal Line"; var ApplyEntriesActionEnabled: Boolean)
    begin
    end;
}
