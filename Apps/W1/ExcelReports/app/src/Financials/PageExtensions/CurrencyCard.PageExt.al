pageextension 4428 "Currency Card" extends "Currency Card"
{
    actions
    {
        addafter("Aged Accounts Payable")
        {
            action("Trial Balance - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View a detailed trial balance for selected currency.';
            }
        }
        addlast(Category_Report)
        {
            actionref(TrialBalanceExcel_Promoted; "Trial Balance - Excel")
            {
            }
        }
    }
}