// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;
using Microsoft.Finance.GeneralLedger.Ledger;

pageextension 4432 "EXR G/L Registers" extends "G/L Registers"
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
                ToolTip = 'Show the chart of accounts with balances and net changes. You can use the report at the close of an accounting period or fiscal year.';
            }
        }
    }
}