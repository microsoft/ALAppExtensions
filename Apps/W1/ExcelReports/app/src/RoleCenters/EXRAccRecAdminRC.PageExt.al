pageextension 4436 "EXR Acc. Rec. Admin RC" extends "Acc. Receivables Adm. RC"
{
    actions
    {
        addafter("Customer - &Balance to Date")
        {
            action(EXRAgedAccountsRecExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Aged Accounts Receivable (Excel)';
                Image = "Report";
                RunObject = Report "EXR Aged Accounts Rec Excel";
                ToolTip = 'View an overview of when your receivables from customers are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
        }
    }
}