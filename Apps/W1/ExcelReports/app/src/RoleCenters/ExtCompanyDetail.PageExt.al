// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.ExcelReports;

using Microsoft.Sales.ExcelReports;
using Microsoft.Purchases.ExcelReports;
using Microsoft.Finance.ExcelReports;
using Microsoft.Utilities;

pageextension 4403 "EXT Company Detail" extends "Company Detail"
{
    actions
    {
        addlast("Excel Reports")
        {
            action(EXRTrialBalanceBudgetExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance/Budget (Preview)';
                Image = "Report";
                RunObject = report "EXR Trial BalanceBudgetExcel";
                ToolTip = 'Open a spreadsheet that shows Trial Balance/Budget data.';
            }
            action(EXRTrialBalanceExcel)
            {
                ApplicationArea = Basic, Suite;
#if not CLEAN25
                Caption = 'Trial Balance (Preview)';
#else
                Caption = 'Trial Balance';
#endif
                Image = "Report";
                RunObject = report "EXR Trial Balance Excel";
                ToolTip = 'Open a spreadsheet that shows Trial Balance Excel data.';
            }
            action(EXRTrialBalbyPeriodExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance by Period (Preview)';
                Image = "Report";
                RunObject = report "EXR Trial Bal by Period Excel";
                ToolTip = 'Open a spreadsheet that shows Trial Balance by Period data.';
            }
            action(EXRTrialBalPrevYearExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance/Previous Year (Preview)';
                Image = "Report";
                RunObject = report "EXR Trial Bal. Prev Year Excel";
                ToolTip = 'Open a spreadsheet that shows Trial Balance/Previous Year data';
            }
            action(EXRAgedAccountsRecExcel)
            {
                ApplicationArea = Basic, Suite;
#if not CLEAN25
                Caption = 'Aged Accounts Receivable (Preview)';
#else
                Caption = 'Aged Accounts Receivable';
#endif
                Image = "Report";
                RunObject = report "EXR Aged Accounts Rec Excel";
                ToolTip = 'Open a spreadsheet that shows the Aged Accounts Receivable data.';
            }
            action(EXRCustomerTopListExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer - Top List (Preview)';
                Image = "Report";
                RunObject = report "EXR Customer Top List";
                ToolTip = 'Open a spreadsheet that shows a list of top customers.';
            }
            action(EXRVendorTopList)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendor - Top List (Preview)';
                Image = "Report";
                RunObject = report "EXR Vendor Top List";
                ToolTip = 'Open a spreadsheet that shows a list of top vendors.';
            }
            action(EXRAgedAccPayableExcel)
            {
                ApplicationArea = Basic, Suite;
#if not CLEAN25
                Caption = 'Aged Accounts Payable (Preview)';
#else
                Caption = 'Aged Accounts Payable';
#endif
                Image = "Report";
                RunObject = report "EXR Aged Acc Payable Excel";
                ToolTip = 'Open a spreadsheet that shows the Aged Accounts Payable data.';
            }
        }
    }
}