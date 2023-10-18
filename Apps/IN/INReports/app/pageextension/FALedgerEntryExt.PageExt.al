// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Ledger;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.Reports;

pageextension 18045 "FA Ledger Entry Ext" extends "FA Ledger Entries"
{
    actions
    {
        addafter("F&unctions")
        {
            group(Report)
            {
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
