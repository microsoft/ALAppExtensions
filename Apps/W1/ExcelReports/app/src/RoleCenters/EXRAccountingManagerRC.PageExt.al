pageextension 4423 "EXR Accounting Manager RC" extends "Accounting Manager Role Center"
{
    actions
    {
        addfirst(reporting)
        {
            action("G/L Trial Balance (Excel)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'G/L Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View, print, or send a report that shows the balances for the general ledger accounts, including the debits and credits. You can use this report to ensure accurate accounting practices.';
            }
        }
        addafter("Bu&dget")
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
        addafter(Action115)
        {
            action(EXRAgedAccountsRecExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Aged Accounts Receivable (Excel)';
                Image = "Report";
                RunObject = Report "EXR Aged Accounts Rec Excel";
                ToolTip = 'View an overview of when your receivables from customers are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
            action(EXRAgedAccountsPayExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Aged Accounts Payable';
                Image = "Report";
                RunObject = Report "EXR Aged Acc Payable Excel";
                ToolTip = 'View an overview of when your payables to vendors are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
        }
    }
}