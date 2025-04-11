pageextension 4434 "G/L Budget Names" extends "G/L Budget Names"
{
    actions
    {
        addfirst(ReportGroup)
        {
            action("Trial Balance/Budget - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance/Budget';
                Image = "Report";
                RunObject = Report "EXR Trial BalanceBudgetExcel";
                ToolTip = 'View budget details for the specified period.';
            }
        }
        addafter(EditBudget_Promoted)
        {
            actionref(TrialBalanceBudgetExcel_Promoted; "Trial Balance/Budget - Excel")
            {
            }
        }
    }
}