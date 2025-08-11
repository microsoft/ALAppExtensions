// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;
using Microsoft.Finance.GeneralLedger.Journal;

pageextension 4429 "EXR General Journal Batches" extends "General Journal Batches"
{
    actions
    {
        addafter("Detail Trial Balance")
        {
            action("Trial Balance - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'Print or save the chart of accounts that have balances and net changes.';
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