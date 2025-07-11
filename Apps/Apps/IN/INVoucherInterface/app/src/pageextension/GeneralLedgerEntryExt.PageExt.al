// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Bank.VoucherInterface;

pageextension 18930 "General Ledger Entry Ext." extends "General Ledger Entries"
{
    actions
    {
        addafter("Value Entries")
        {
            action(Narration)
            {
                Caption = 'Narration';
                ToolTip = 'Select this option to enter narration for a particular line.';
                ApplicationArea = Basic, Suite;
                RunObject = page "Posted Narration";
                RunPageLink = "Entry No." = filter(0), "Transaction No." = field("Transaction No.");
                Promoted = true;
                PromotedCategory = Process;
                Image = Description;
            }
            action("Line Narration")
            {
                Caption = 'Line Narration';
                ToolTip = 'Select this option to enter narration for the voucher.';
                ApplicationArea = Basic, Suite;
                RunObject = page "Posted Narration";
                RunPageLink = "Entry No." = field("Entry No."), "Transaction No." = field("Transaction No.");
                Promoted = true;
                PromotedCategory = Process;
                Image = LineDescription;
            }
        }
    }
}
