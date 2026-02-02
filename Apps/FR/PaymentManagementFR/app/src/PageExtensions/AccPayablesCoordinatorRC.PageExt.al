// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.RoleCenters;

pageextension 10832 "Acc. Payables Coordinator RC" extends "Acc. Payables Coordinator RC"
{
    actions
    {
        addafter(Action1120006)
        {
            action("Payments Lists FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payments Lists';
                Image = "Report";
                RunObject = Report "Payment List FR";
                ToolTip = 'View a list of payments.';
            }
            action("GL/Vend. Ledger Reconciliation FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'GL/Vend. Ledger Reconciliation';
                Image = "Report";
                RunObject = Report "GL/Vend Ledger Reconciliation";
                ToolTip = 'View or print a separate page for each vendor that sums up amounts from general ledger transactions based on payments and posted invoices. This is useful when you want to reconcile general ledger entries with vendor ledger entries.';
            }
        }
        addafter(PaymentJournals)
        {
            action("Payment Slips FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Slips';
                RunObject = Page "Payment Slip List FR";
                ToolTip = 'View a list of payment slips.';
            }
        }
        addafter("G/L Registers")
        {
            action("Payment Slip List Archives FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Slip List Archives';
                RunObject = Page "Payment Slip List Archive FR";
                ToolTip = 'View a list of payment slips that have been posted and archived.';
            }
        }
        addafter("Payment &Journal")
        {
            action("Payment Slip FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Slip';
                RunObject = Page "Payment Slip FR";
                ToolTip = 'Use payment slips to manage customer and vendor payments. ';
            }
            action("Look/Edit Payment Line FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Look/Edit Payment Line';
                RunObject = Page "View/Edit Payment Line FR";
                ToolTip = 'View and edit all payment lines that belong to a payment class. The window shows a line for each payment status. ';
            }
            action("Payment Report FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Report';
                RunObject = Page "Payment Report FR";
                ToolTip = 'View all payment documents that belong to a payment class and have the same status.';
            }
        }
        addafter(VendorPayments)
        {
            action("Archive Payment Journals FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Archive Payment Journals';
                Image = "Report";
                RunObject = Report "Archive Payment Slips FR";
                ToolTip = 'Archive payment journals to separate them from active journals. You can enter criteria to specify the journals to archive.';
            }
            action("Create Payment Slip FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create Payment Slip';
                RunObject = Codeunit "Payment Management FR";
                ToolTip = 'Manage information about customer and vendor payments.';
            }
        }
    }
}