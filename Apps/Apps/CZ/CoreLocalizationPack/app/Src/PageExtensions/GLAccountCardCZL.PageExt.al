// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Account;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Reports;

pageextension 11766 "G/L Account Card CZL" extends "G/L Account Card"
{
    layout
    {
        addafter("Last Date Modified")
        {
            field("G/L Account Group CZL"; Rec."G/L Account Group CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Defines the type of G/L account group for internal accounting areas.';
            }
        }
    }
    actions
    {
        addafter("Trial Balance by Period")
        {
            action("General Ledger CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'General Ledger';
                Image = Report;
                RunObject = report "General Ledger CZL";
                ToolTip = 'View, print, or send a report that shows a list of general ledger entries sorted by G/L Account and accounting period. You can use this report at the close of an accounting period or fiscal year and to document your general ledger transactions according law requirements.';
            }
            action("General Ledger Document CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'General Ledger Document';
                Image = Report;
                RunObject = report "General Ledger Document CZL";
                ToolTip = 'View, print, or send a report of transactions posted to general ledger in form of a document.';
            }
            action("Turnover Report by Glob. Dim. CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Turnover Report by Global Dimensions';
                Image = Report;
                RunObject = report "Turnover Rpt. by Gl. Dim. CZL";
                ToolTip = 'View, print, or send a report that shows the opening balance by general ledger account, the movements in the selected period of month, quarter, or year, and the resulting closing balance. You can use this report at the close of an accounting period or fiscal year and to document your general ledger transactions according law requirements.';
            }
            action("Joining G/L Account Adjustment CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Joining G/L Account Adjustment';
                Image = Report;
                RunObject = report "Joining G/L Account Adj. CZL";
                ToolTip = 'Verify that selected G/L account balance is cleared for selected document number.';
            }
            action("G/L Account Group Posting Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'G/L Account Group Posting Check';
                Image = Report;
                RunObject = report "G/L Acc. Group Post. Check CZL";
                ToolTip = 'View, print, or send a report that shows a list of general ledger entries sorted by date of posting and document number with different G/L account groups.';
            }
        }
    }
}
