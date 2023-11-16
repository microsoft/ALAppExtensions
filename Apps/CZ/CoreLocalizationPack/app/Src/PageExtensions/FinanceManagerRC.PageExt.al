// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Bank.Reports;
using Microsoft.Finance;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Reports;
using Microsoft.Finance.VAT.Reporting;
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
                RunObject = report "VAT Statement CZL";
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
            action("General Ledger Document CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'General Ledger Document';
                Image = Report;
                RunObject = report "General Ledger Document CZL";
                ToolTip = 'View, print, or send a report of transactions posted to general ledger in form of a document.';
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
    }
}
