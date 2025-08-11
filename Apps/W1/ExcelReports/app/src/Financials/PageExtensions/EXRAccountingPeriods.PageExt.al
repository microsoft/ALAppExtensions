// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;
using Microsoft.Foundation.Period;

pageextension 4425 "EXR Accounting Periods" extends "Accounting Periods"
{
    actions
    {
        addafter("Trial Balance by Period")
        {
            action("Trial Balance - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'Show the chart of accounts with balances and net changes. You can use the report at the close of an accounting period or fiscal year.';
            }
        }
    }
}