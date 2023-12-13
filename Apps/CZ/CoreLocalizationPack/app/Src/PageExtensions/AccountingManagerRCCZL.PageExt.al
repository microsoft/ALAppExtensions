// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Finance.FinancialReports;

pageextension 11796 "Accounting Manager RC CZL" extends "Accounting Manager Role Center"
{
    actions
    {
        addafter("&Closing Trial Balance")
        {
            action("Balance Sheet CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Sheet';
                Image = PrintReport;
                RunObject = report "Balance Sheet CZL";
                ToolTip = 'Open the report for balance sheet.';
            }
            action("Income Statement CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Income Statement';
                Image = PrintReport;
                RunObject = report "Income Statement CZL";
                ToolTip = 'Open the report for income statement.';
            }
        }
    }
}
