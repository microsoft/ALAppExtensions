// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;
using Microsoft.Finance.GeneralLedger.Budget;

pageextension 4434 "EXR G/L Budget Names" extends "G/L Budget Names"
{
    actions
    {
        addfirst(ReportGroup)
        {
            action("Trial Balance/Budget - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance/Budget (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial BalanceBudgetExcel";
                ToolTip = 'View budget details for the specified period.';
            }
        }
        addafter(EditBudget_Promoted)
        {
            actionref(TrialBalanceBudgetExcel_Promoted; "Trial Balance/Budget - Excel")
            {
            }
        }
    }
}