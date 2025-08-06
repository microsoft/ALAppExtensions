#pragma warning disable AA0247
pageextension 4406 EXRFinRoleCenter extends "Finance Manager Role Center"
{
    actions
    {
        addafter(Group11)
        {
            group("Excel Reports")
            {
                Caption = 'Excel Reports';

                action(EXRTrialBalbyPeriodExcel)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Trial Balance by Period (Excel)';
                    Image = "Report";
                    RunObject = report "EXR Trial Bal by Period Excel";
                    ToolTip = 'Open a spreadsheet that shows Trial Balance by Period data.';
                }
                action(EXRTrialBalPrevYearExcel)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Trial Balance/Previous Year (Excel)';
                    Image = "Report";
                    RunObject = report "EXR Trial Bal. Prev Year Excel";
                    ToolTip = 'Open a spreadsheet that shows Trial Balance/Previous Year data';
                }
                action(EXRConsolidatedTrialBalance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Consolidated Trial Balance (Excel)';
                    Image = "Report";
                    RunObject = report "EXR Consolidated Trial Balance";
                    ToolTip = 'Open an Excel workbook that shows the G/L entries totals in the different business units.';
                }
            }
        }
        addlast(Group45)
        {
            action(EXRFixedAssetAnalysisExcelG45)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Fixed Asset Analysis (Excel)';
                Image = "Report";
                RunObject = report "EXR Fixed Asset Analysis Excel";
                ToolTip = 'Open an Excel workbook that shows a comparison of fixed asset values across a date range.';
            }
            action(EXRFixedAssetDetailsExcelG45)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Fixed Asset Details (Excel)';
                Image = "Report";
                RunObject = report "EXR Fixed Asset Details Excel";
                ToolTip = 'Open an Excel workbook that shows fixed asset ledger entries.';
            }
            action(EXRFixedAssetProjectedG45)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Fixed Asset Projected Value (Excel)';
                Image = "Report";
                RunObject = report "EXR Fixed Asset Projected";
                ToolTip = 'Open an Excel workbook that shows posted fixed asset ledger entries and projected fixed asset ledger entries.';
            }

        }
        addafter("Customer - Labels")
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
        addafter("Vendor - Summary Aging")
        {
            action(EXRVendorTopList)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendor - Top List (Excel)';
                Image = "Report";
                RunObject = Report "EXR Vendor Top List";
                ToolTip = 'View a list of the vendors from whom you purchase the most or to whom you owe the most.';
            }
        }
        addafter("Book Value 02")
        {
            action(EXRFixedAssetDetailsExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Fixed Asset Details (Excel)';
                Image = "Report";
                RunObject = report "EXR Fixed Asset Details Excel";
                ToolTip = 'View detailed information about the fixed asset ledger entries that have been posted to a specified depreciation book for each fixed asset.';
            }
        }
        addafter("Acquisition List")
        {
            action(EXRFixedAssetAnalysisExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Fixed Asset Analysis (Excel)';
                Image = "Report";
                RunObject = report "EXR Fixed Asset Analysis Excel";
                ToolTip = 'Open an Excel workbook that shows a comparison of fixed asset values across a date range.';
            }
        }
        addafter(List1)
        {
            action(EXRFixedAssetProjected)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Fixed Asset Projected Value (Excel)';
                Image = "Report";
                RunObject = report "EXR Fixed Asset Projected";
                ToolTip = 'Open an Excel workbook that shows posted fixed asset ledger entries and projected fixed asset ledger entries.';
            }
        }
        addafter("Account Schedule")
        {
            action(EXRTrialBalanceExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = report "EXR Trial Balance Excel";
                ToolTip = 'Open a spreadsheet that shows Trial Balance Excel data.';
            }
            action(EXRTrialBalanceBudgetExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance/Budget (Excel)';
                Image = "Report";
                RunObject = report "EXR Trial BalanceBudgetExcel";
                ToolTip = 'Open a spreadsheet that shows Trial Balance/Budget data.';
            }
        }
        addafter("Customer - Sales List")
        {
            action(EXRAgedAccountsRecExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Aged Accounts Receivable (Excel)';
                Image = "Report";
                RunObject = report "EXR Aged Accounts Rec Excel";
                ToolTip = 'Open a spreadsheet that shows the Aged Accounts Receivable data.';
            }
        }
        addfirst(Group40)
        {
            action(EXRAgedAccPayableExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Aged Accounts Payable (Excel)';
                Image = "Report";
                RunObject = report "EXR Aged Acc Payable Excel";
                ToolTip = 'Open a spreadsheet that shows the Aged Accounts Payable data.';
            }
        }
    }
}
