namespace Microsoft.Sustainability.RoleCenters;

page 6240 "Sustainability Goal Cue"
{
    PageType = CardPart;
    SourceTable = "Sustainability Goal Cue";
    RefreshOnActivate = true;
    Caption = 'Goals';

    layout
    {
        area(Content)
        {
            cuegroup(General)
            {
                CuegroupLayout = Wide;
                ShowCaption = false;
                field("Realized % for CO2"; "Realized % for CO2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for CO2';
                }
                field("Realized % for CH4"; "Realized % for CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for CH4';
                }
                field("Realized % for N2O"; "Realized % for N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for N2O';
                }
                field("CO2 % vs Baseline"; "CO2 % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CO2 % vs Baseline';
                }
                field("CH4 % vs Baseline"; "CH4 % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CH4 % vs Baseline';
                }
                field("N2O % vs Baseline"; "N2O % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'N2O % vs Baseline';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        ComputeSustGoalCue.GetLatestSustainabilityGoalCue(Rec);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ComputeSustGoalCue.GetLatestSustainabilityGoalCue(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        ComputeSustGoalCue.GetLatestSustainabilityGoalCue(Rec);
    end;

    var
        ComputeSustGoalCue: Codeunit "Compute Sust. Goal Cue";
}