// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.RoleCenters;

pageextension 10839 "Finance Manager Role Center" extends "Finance Manager Role Center"
{
    actions
    {
        addafter("Bank Account Journal")
        {
            action("GL/Cust. Ledger Reconciliation FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'GL/Cust. Ledger Reconciliation';
                RunObject = report "GL/Cust Ledger Reconciliation";
                Tooltip = 'Run the GL/Cust Ledger Reconciliation report.';
            }
            action("GL/Vend. Ledger Reconciliation FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'GL/Vend. Ledger Reconciliation';
                RunObject = report "GL/Vend Ledger Reconciliation";
                Tooltip = 'Run the GL/Vend Ledger Reconciliation report.';
            }
        }
        addafter("Payment Registration")
        {
            action("Payment Slips FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Slips';
                RunObject = page "Payment Slip List FR";
                Tooltip = 'Open the Payment Slip List page.';
            }
        }
        addafter(Group15)
        {
            group("Group62 FR")
            {
                Caption = 'Payment Slip';
                action("View/Edit Payment Lines FR")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View/Edit Payment Lines';
                    RunObject = page "View/Edit Payment Line FR";
                    Tooltip = 'Open the View/Edit Payment Line page.';
                }
                action("Payment Report FR")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Report';
                    RunObject = page "Payment Report FR";
                    Tooltip = 'Open the Payment Report page.';
                }
                action("Archive Payment Slips FR")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Archive Payment Slips';
                    RunObject = report "Archive Payment Slips FR";
                    Tooltip = 'Run the Archive Payment Slips report.';
                }
            }
        }
        addafter("Cash Flow Ledger Entries1")
        {
            action("Payment Slip Archive FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Slip Archive';
                RunObject = page "Payment Slip List Archive FR";
                Tooltip = 'Open the Payment Slip List page.';
            }
        }
        addafter("Direct Debit Collections")
        {
            action("Payment Slips1 FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Slips';
                RunObject = page "Payment Slip List FR";
                Tooltip = 'Open the Payment Slip List page.';
            }
        }
        addafter("Credit Memos1")
        {
            action("Payment Slips2 FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Slips';
                RunObject = page "Payment Slip List FR";
                Tooltip = 'Open the Payment Slip List page.';
            }
        }
    }
}