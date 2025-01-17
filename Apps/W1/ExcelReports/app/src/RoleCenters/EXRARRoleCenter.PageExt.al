pageextension 4405 EXRARRoleCenter extends "Account Receivables"
{
    actions
    {
        addlast(Reporting)
        {
            group("Excel Reports")
            {
                Caption = 'Excel Reports';
                Image = Excel;

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
            }
        }
    }
}
