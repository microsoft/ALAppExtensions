// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Finance.FinancialReports;

pageextension 11293 "SE Accounting Manager RC" extends "Accounting Manager Role Center"
{
    actions
    {
        addafter("&Closing Trial Balance")
        {
            action("SE Balance Sheet")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Sheet - SE';
                Image = "Report";
                RunObject = Report "SE Balance sheet";
                ToolTip = 'View assets, liabilities, and equity on the balance sheet.';
            }

            action("SE Income Statement")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Income Statement - SE';
                Image = "Report";
                RunObject = Report "SE Income statement";
                ToolTip = 'View a report that shows your company''s income and expenses.';
            }
        }
    }
}
