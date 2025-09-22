// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.ExcelReports;
using Microsoft.RoleCenters;
using Microsoft.Finance.ExcelReports;

pageextension 4439 "EXR CEO and President RC" extends "CEO and President Role Center"
{
    actions
    {
        addafter("Customer - &Balance")
        {
            action(EXRCustomerTopListExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer - Top List (Excel)';
                Image = "Report";
                RunObject = Report "EXR Customer Top List";
                ToolTip = 'View which customers purchase the most or owe the most in a selected period. Only customers that have either purchases during the period or a balance at the end of the period will be included.';
            }
        }
        addafter("Recei&vables-Payables")
        {
            action(EXRTrialBalanceBudgetExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance/Budget (Excel)';
                Image = "Report";
                RunObject = report "EXR Trial BalanceBudgetExcel";
                ToolTip = 'View a trial balance in comparison to a budget. You can choose to see a trial balance for selected dimensions. You can use the report at the close of an accounting period or fiscal year.';
            }
        }
    }
}