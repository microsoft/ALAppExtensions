pageextension 4435 Reminder extends Reminder
{
    actions
    {
        addafter("Customer - Detail Trial Bal.")
        {
            action("Aged Accounts Receivable - Excel")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Aged Accounts Receivable (Excel)';
                Image = "Report";
                RunObject = Report "EXR Aged Accounts Rec Excel";
                ToolTip = 'View an overview of when customer payments are due or overdue, divided into four periods. You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
        }
    }
}