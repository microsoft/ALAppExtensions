// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Receivables;

using Microsoft.Bank.VoucherInterface;

pageextension 18936 "Cust. Ledger Entry Ext" extends "Customer Ledger Entries"
{
    actions
    {
        addafter(AppliedEntries)
        {
            action(Narration)
            {
                Caption = 'Narration';
                ToolTip = 'Select Voucher Narration option to enter narration for a particular line.';
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
                ToolTip = 'Select this option to enter narration for a particular line.';
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
