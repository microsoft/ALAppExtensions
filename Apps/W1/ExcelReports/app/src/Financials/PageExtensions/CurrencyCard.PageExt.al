pageextension 4428 "Currency Card" extends "Currency Card"
{
    actions
    {
        addafter("Foreign Currency Balance")
        {
            action("Aged Accounts Receivable - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Aged Accounts Receivable (Excel)';
                Image = "Report";
                RunObject = Report "EXR Aged Accounts Rec Excel";
                ToolTip = 'View an overview of when customer payments are due or overdue, divided into four periods. You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
            action("Aged Accounts Payable - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Aged Accounts Payable';
                Image = "Report";
                RunObject = Report "EXR Aged Acc Payable Excel";
                ToolTip = 'View an overview of when your payables to vendors are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
            action("Trial Balance - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View a detailed trial balance for selected currency.';
            }
        }
        addafter("Foreign Currency Balance_Promoted")
        {
            actionref(AgedAccountsReceivableExcel_Promoted; "Aged Accounts Receivable - Excel")
            {
            }
            actionref(AgedAccountsPayableExcel_Promoted; "Aged Accounts Payable - Excel")
            {
            }
            actionref(TrialBalanceExcel_Promoted; "Trial Balance - Excel")
            {
            }
        }
    }
}