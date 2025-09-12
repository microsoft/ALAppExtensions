// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;
using Microsoft.Finance.GeneralLedger.Account;

pageextension 4431 "EXR G/L Account List" extends "G/L Account List"
{
    actions
    {
        addfirst(reporting)
        {
            action("Trial Balance - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View general ledger account balances and activities for all the selected accounts, one transaction per line.';
            }
        }
        addfirst(Category_Report)
        {
            actionref(TrialBalanceExcel_Promoted; "Trial Balance - Excel")
            {
            }
        }
    }
}