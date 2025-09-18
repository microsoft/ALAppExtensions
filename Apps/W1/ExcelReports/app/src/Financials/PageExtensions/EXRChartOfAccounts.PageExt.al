// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;
using Microsoft.Finance.GeneralLedger.Account;

pageextension 4427 "EXR Chart of Accounts" extends "Chart of Accounts"
{
    actions
    {
        addlast(reporting)
        {
            action("Trial Balance - Excel")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View the chart of accounts that have balances and net changes.';
            }
        }
        addlast(Category_Report)
        {
            actionref(TrialBalanceExcel_Promoted; "Trial Balance - Excel")
            {
            }
        }
    }
}