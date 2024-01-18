// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.GeneralLedger.Posting;

pageextension 31241 "General Ledger Entries CZA" extends "General Ledger Entries"
{
    layout
    {
        addafter(Amount)
        {
            field("Applied Amount CZA"; Rec."Applied Amount CZA")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the applied amount for the general ledger entry.';
            }
            field(RemainingAmountCZAField; Rec.RemainingAmountCZA())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Remaining Amount';
                Editable = false;
                ToolTip = 'Specifies the remaining amount of general ledger entries';
            }
            field("Closed CZA"; Rec."Closed CZA")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies to indicate that the general ledger entry is closed.';
            }
        }
    }

    actions
    {
        addlast("F&unctions")
        {
            action("Apply Entries CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Apply Entries';
                Image = ApplyEntries;
                ShortCutKey = 'Shift+F11';
                ToolTip = 'The function allows you to apply general ledger entries.';

                trigger OnAction()
                var
                    GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
                begin
                    GLEntryPostApplicationCZA.ApplyGLEntry(Rec);
                end;
            }
            action("Unapply Entries CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Unapply Entries';
                Image = UnApply;
                ToolTip = 'The function allows you to cancel applied general ledger entries.';

                trigger OnAction()
                var
                    GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
                begin
                    GLEntryPostApplicationCZA.UnApplyGLEntry(Rec."Entry No.");
                end;
            }
        }
        addlast("Ent&ry")
        {
            action("Applied Entries CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Applied Entries';
                Image = Approve;
                RunObject = Page "Applied G/L Entries CZA";
                RunPageOnRec = true;
                ToolTip = 'Open the page with applied G/L entries.';
            }
        }

    }
}
