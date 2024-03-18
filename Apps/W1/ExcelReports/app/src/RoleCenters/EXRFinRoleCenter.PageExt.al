pageextension 4406 EXRFinRoleCenter extends "Finance Manager Role Center"
{
    actions
    {
        addafter(Group11)
        {
            group("Excel Reports")
            {
                Caption = 'Excel Reports';

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
                    Caption = 'Trial Balance (Preview)';
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
                    Caption = 'Aged Accounts Receivable (Preview)';
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
                    Caption = 'Aged Accounts Payable (Preview)';
                    Image = "Report";
                    RunObject = report "EXR Aged Acc Payable Excel";
                    ToolTip = 'Open a spreadsheet that shows the Aged Accounts Payable data.';
                }
            }
        }
    }
}
