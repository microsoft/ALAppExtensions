namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Finance.Analysis;

pageextension 2625 StatAccAnalysisView extends "Analysis View Card"
{
    layout
    {
        addafter("Account Filter")
        {
            group(StatisticalAccountFilterGroup)
            {
                Visible = Rec."Account Source" <> Rec."Account Source"::"Statistical Account";
                ShowCaption = false;
                field(StatisticalAccountFilter; Rec."Statistical Account Filter")
                {
                    ApplicationArea = All;
                    Caption = 'Statistical Account Filter';
                    ToolTip = 'Specifies which statistical accounts are shown in the analysis view.';
                }
            }
        }
    }
}