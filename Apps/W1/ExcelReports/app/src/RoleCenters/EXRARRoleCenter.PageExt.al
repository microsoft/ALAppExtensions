#pragma warning disable AA0247
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
                    Caption = 'Trial Balance/Budget (Excel)';
                    Image = "Report";
                    RunObject = report "EXR Trial BalanceBudgetExcel";
                    ToolTip = 'Open a spreadsheet that shows Trial Balance/Budget data.';
                }
                action(EXRTrialBalanceExcel)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Trial Balance (Excel)';
                    Image = "Report";
                    RunObject = report "EXR Trial Balance Excel";
                    ToolTip = 'Open a spreadsheet that shows Trial Balance Excel data.';
                }
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
                action(EXRCustomerTopListExcel)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer - Top List (Excel)';
                    Image = "Report";
                    RunObject = report "EXR Customer Top List";
                    ToolTip = 'Open a spreadsheet that shows a list of top customers.';
                }
            }
        }
        addafter("Customer - &Balance to Date")
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
    }
}
