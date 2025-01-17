// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Bank.Reports;
using Microsoft.Purchases.Reports;
using Microsoft.Purchases.Payables;
using Microsoft.Finance;
using Microsoft.Inventory.Reports;
using Microsoft.Inventory.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Reports;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Reports;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Sales.Receivables;
using Microsoft.Inventory.Reconciliation;

pageextension 11793 "Finance Manager RC CZL" extends "Finance Manager Role Center"
{
    actions
    {
        addafter("VAT Registration No. Check")
        {
            action("VAT &Statement CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT &Statement';
                Image = Report;
                RunObject = report "VAT Statement";
                ToolTip = 'View a statement of posted VAT and calculate the duty liable to the customs authorities for the selected period.';
            }
        }
        addafter("VAT- VIES Declaration Disk")
        {
            action("G/L VAT Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'G/L VAT Reconciliation';
                RunObject = report "G/L VAT Reconciliation CZL";
            }
        }
        addlast(Group6)
        {
            action(EETEntriesCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'EET Entries';
                RunObject = page "EET Entries CZL";
                ToolTip = 'Open the list of EET entries.';
            }
        }
        addlast(Group7)
        {
            action("Turnover Rpt. by Glob. Dim. CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Turnover report by Glob. Dim.';
                Image = Report;
                RunObject = report "Turnover Rpt. by Gl. Dim. CZL";
                ToolTip = 'View, print, or send a report that shows the opening balance by general ledger account, the movements in the selected period of month, quarter, or year, and the resulting closing balance. You can use this report at the close of an accounting period or fiscal year and to document your general ledger transactions according law requirements.';
            }
            action("General Ledger Document CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'General Ledger Document';
                Image = Report;
                RunObject = report "General Ledger Document CZL";
                ToolTip = 'View, print, or send a report of transactions posted to general ledger in form of a document.';
            }
            action("General Journal CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'General Journal';
                Image = Report;
                RunObject = report "General Journal CZL";
                ToolTip = 'Run the General Journal report.';
            }
        }
        addlast(Group40)
        {
            action("All Payments on Hold CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'All Payments on Hold';
                Image = Report;
                RunObject = report "All Payments on Hold CZL";
                ToolTip = 'View a list of all vendor ledger entries on which the On Hold field is marked. ';
            }
        }
        addlast(Group9)
        {
            action("General Ledger CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'General Ledger';
                Image = Report;
                RunObject = report "General Ledger CZL";
                ToolTip = 'View, print, or send a report that shows a list of general ledger entries sorted by G/L Account and accounting period. You can use this report at the close of an accounting period or fiscal year and to document your general ledger transactions according law requirements.';
            }
            action("Turnover Report by Glob. Dim. CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Turnover report by Glob. Dim.';
                Image = Report;
                RunObject = report "Turnover Rpt. by Gl. Dim. CZL";
                ToolTip = 'View, print, or send a report that shows the opening balance by general ledger account, the movements in the selected period of month, quarter, or year, and the resulting closing balance. You can use this report at the close of an accounting period or fiscal year and to document your general ledger transactions according law requirements.';
            }
        }
        addlast(Group10)
        {
            action("Joining Bank. Acc. Adjustment CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Joining Bank. Acc. Adjustment';
                Image = Report;
                RunObject = report "Joining Bank. Acc. Adj. CZL";
                ToolTip = 'Verify that selected bank account balance is cleared for selected document number.';
            }
            action("Joining G/L Account Adjustment CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Joining G/L Account Adjustment';
                Image = Report;
                RunObject = report "Joining G/L Account Adj. CZL";
                ToolTip = 'Verify that selected G/L account balance is cleared for selected document number.';
            }
        }
        addlast(Group53)
        {
            action("Inventory - G/L Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Inventory - G/L Reconciliation Enhanced';
                RunObject = page "Inv. G/L Reconciliation CZL";
            }
            action("Posted Inventory Document CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Posted Inventory Document';
                Image = Report;
                RunObject = report "Posted Inventory Document CZL";
                ToolTip = 'Run the Posted Inventory Document report.';
            }
            action("Phys. Inventory Document CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Physical Inventory Counting Document';
                Image = Report;
                RunObject = report "Phys. Inventory Document CZL";
                ToolTip = 'Run the Phys. Inventory Document report.';
            }
        }
        addafter("Reconcile Cust. and Vend. Accs")
        {
            action("Reconcile Bank Account Entry CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reconcile Bank Account Entry';
                Image = Report;
                RunObject = report "Recon. Bank Account Entry CZL";
                ToolTip = 'Verify that the bank account balances from bank accout ledger entries match the balances on corresponding G/L accounts from the G/L entries.';
            }
        }
        addlast(Group40)
        {
            action("Open Vend. Entries to Date CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Vendor Entries to Date';
                Image = Report;
                RunObject = report "Open Vend. Entries to Date CZL";
                Tooltip = 'Run the Open Vend. Entries to Date report.';
            }
            action("Vendor-Bal. Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendor - Balance Reconciliation';
                Image = Report;
                RunObject = report "Vendor-Bal. Reconciliation CZL";
                Tooltip = 'Run the Vendor-Bal. Reconciliation report.';
            }
            action("Quantity Received Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Quantity Received Check';
                Image = Report;
                RunObject = report "Quantity Received Check CZL";
                Tooltip = 'Run the Quantity Received Check report.';
            }
        }
        addlast(Group34)
        {
            action("Open Cust. Entries to Date CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Customer Entries to Date';
                Image = Report;
                RunObject = report "Open Cust. Entries to Date CZL";
                Tooltip = 'Run the Open Cust. Entries to Date report.';
            }
            action("Cust.- Bal. Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer - Bal. Reconciliation';
                Image = Report;
                RunObject = report "Cust.- Bal. Reconciliation CZL";
                Tooltip = 'Run the Cust.- Bal. Reconciliation report.';
            }
            action("Quantity Shipped Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Quantity Shipped Check';
                Image = Report;
                RunObject = report "Quantity Shipped Check CZL";
                Tooltip = 'Run the Quantity Shipped Check report.';
            }
        }
        addlast(Group2)
        {
            action("Documentation for VAT CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Documentation for VAT';
                Image = Report;
                RunObject = report "Documentation for VAT CZL";
                Tooltip = 'Run the Documentation for VAT report.';
            }
            action("VAT Documents List CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Documents';
                Image = Report;
                RunObject = report "VAT Documents List CZL";
                Tooltip = 'Run the VAT Documents List report.';
            }
            action("Unreliable Payer List CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Unreliable Payer List';
                Image = Report;
                RunObject = report "Unreliable Payer List CZL";
                Tooltip = 'Run the Unreliable Payer List report.';
            }
        }
    }
}
