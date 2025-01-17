// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Sales.Receivables;

pageextension 11767 "Customer List CZL" extends "Customer List"
{
    layout
    {
        addafter(Contact)
        {
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the customer''s VAT registration number for customers in EU countries/regions.';
            }
            field("Registration Number CZL"; Rec."Registration Number")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer.';
            }
        }
    }

    actions
    {
        addafter(ReportCustomerPaymentReceipt)
        {
            action("Open Cust. Entries to Date CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Customer Entries to Date';
                Image = Report;
                RunObject = report "Open Cust. Entries to Date CZL";
                ToolTip = 'View, print, or send a report that shows Open Customer Entries to Date';
            }
        }
        addlast(reporting)
        {
            action("Balance Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Reconciliation';
                Image = Balance;
                RunObject = report "Cust.- Bal. Reconciliation CZL";
                ToolTip = 'Open the report for customer''s balance reconciliation.';
            }
        }
        addlast(Category_Report)
        {
            actionref("Balance Reconciliation CZL_Promoted"; "Balance Reconciliation CZL")
            {
            }
        }
    }
}
