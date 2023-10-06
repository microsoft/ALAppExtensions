// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Ledger;

using Microsoft.Bank.VoucherInterface;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.Reports;

pageextension 18046 "Bank Acc Ledg Entry Ext." extends "Bank Account Ledger Entries"
{
    actions
    {
        addafter("F&unctions")
        {
            group(Report)
            {
                action(Narration)
                {
                    Caption = 'Narration';
                    ToolTip = 'Select Voucher Narration option to check narration for a particular line';
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Posted Narration";
                    RunPageLink = "Entry No." = filter(0), "Transaction No." = field("Transaction No.");
                    Promoted = true;
                    PromotedCategory = Process;
                    Image = Description;
                }
                action("Print Voucher")
                {
                    Caption = 'Print Voucher';
                    ToolTip = 'Select this option to take print of the voucher.';
                    ApplicationArea = Basic, Suite;
                    Image = PrintVoucher;
                    Ellipsis = true;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        GLEntry: Record "G/L Entry";
                    begin
                        GLEntry.SetCurrentKey("Transaction No.");
                        GLEntry.SetRange("Transaction No.", Rec."Transaction No.");
                        if GLEntry.FindFirst() then
                            Report.RunModal(Report::"Posted Voucher", true, true, GLEntry);
                    end;
                }
            }
        }
    }
}
