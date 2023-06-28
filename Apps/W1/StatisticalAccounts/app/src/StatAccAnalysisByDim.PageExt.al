pageextension 2626 "Stat. Acc. Analysis By Dim." extends "Analysis by Dimensions"
{
    actions
    {
        addafter(ShowMatrix)
        {
            action(OpenAnalysisByDimensionStatisticalAccounts)
            {
                ApplicationArea = All;
                Caption = 'Show Statistical Account Analysis';
                Image = ShowChart;
                ToolTip = 'Show Statistical Account Analysis.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;
                Visible = OpenAnalysisByDimensionStatisticalAccountsVisible;

                trigger OnAction()
                var
                    TempAnalysisbyDimParameters: Record "Analysis by Dim. Parameters" temporary;
                begin
                    TempAnalysisbyDimParameters.Copy(Rec);
                    TempAnalysisbyDimParameters."Account Filter" := StatisticalAccountFilter;
                    TempAnalysisbyDimParameters."Analysis Account Source" := TempAnalysisbyDimParameters."Analysis Account Source"::"Statistical Account";
                    TempAnalysisByDimParameters.Insert();
                    PAGE.RUN(PAGE::"Analysis by Dimensions", TempAnalysisByDimParameters);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        AnalysisView: Record "Analysis View";
    begin
        Clear(StatisticalAccountFilter);
        if not AnalysisView.Get(Rec."Analysis View Code") then
            exit;
        StatisticalAccountFilter := AnalysisView."Statistical Account Filter";
        OpenAnalysisByDimensionStatisticalAccountsVisible := (StatisticalAccountFilter <> '') and (Rec."Analysis Account Source" <> Rec."Analysis Account Source"::"Statistical Account");
    end;

    var
        StatisticalAccountFilter: Text[250];
        OpenAnalysisByDimensionStatisticalAccountsVisible: Boolean;
}