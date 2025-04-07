pageextension 4426 "Bank Account List" extends "Bank Account List"
{
    actions
    {
        addafter("Receivables-Payables")
        {
            action("Trial Balance - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View a detailed trial balance for the selected bank account.';
            }
        }
    }
}