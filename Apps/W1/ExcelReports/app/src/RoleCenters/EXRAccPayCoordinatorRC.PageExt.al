pageextension 4437 "EXR Acc. Pay. Coordinator RC" extends "Acc. Payables Coordinator RC"
{
    actions
    {
        addafter("Vendor - &Balance to date")
        {
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