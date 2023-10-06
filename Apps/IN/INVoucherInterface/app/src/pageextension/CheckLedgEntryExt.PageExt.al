// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Check;

using Microsoft.Bank.VoucherInterface;

pageextension 18951 "Check Ledg Entry Ext" extends "Check Ledger Entries"
{
    layout
    {
        addafter(Description)
        {
            field("Stale Cheque"; Rec."Stale Cheque")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the cheque has been marked as stale on the check ledger entry.';
            }
            field("Stale Cheque Expiry Date"; Rec."Stale Cheque Expiry Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date before which the cheque cannot be marked as stale cheque on the check ledger entry.';
            }
            field("Cheque Stale Date"; Rec."Cheque Stale Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque stale date on the check ledger entry.';
            }
        }
    }

    actions
    {
        addafter("Void Check")
        {
            group(Check)
            {
                Caption = 'Chec&k';
                Image = Check;

                action("Stale Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Stale Check';
                    Image = StaleCheck;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Select this option to  mark a check as stale. This function will update Stale Check, Check Stale Date and Entry Status fields to indicate that the check is void.';

                    trigger OnAction()
                    var
                        CheckManagementSubscriber: Codeunit "Check Management Subscriber";
                    begin
                        CheckManagementSubscriber.FinancialStaleCheck(Rec);
                    end;
                }
            }
        }
    }
}
