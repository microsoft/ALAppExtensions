// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;
using Microsoft.Bank.BankAccount;

pageextension 4426 "EXR Bank Account List" extends "Bank Account List"
{
    actions
    {
        addafter("Receivables-Payables")
        {
            action("Trial Balance - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View a detailed trial balance for the selected bank account.';
            }
        }
    }
}