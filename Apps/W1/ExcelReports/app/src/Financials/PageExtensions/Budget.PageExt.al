pageextension 4433 Budget extends Budget
{
    actions
    {
        addfirst(ReportGroup)
        {
            action("Trial Balance/Budget - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance/Budget (Obsolete)';
                Image = "Report";
                RunObject = Report "EXR Trial BalanceBudgetExcel";
                ToolTip = 'View budget details for the specified period.';
            }
        }
        addafter(ReportBudget_Promoted)
        {
            actionref(TrialBalanceBudgetExcel_Promoted; "Trial Balance/Budget - Excel")
            {
            }
        }
    }
}