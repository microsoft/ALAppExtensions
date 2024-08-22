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
                field("Realized % for CO2"; Rec."Realized % for CO2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for CO2';
                    ToolTip = 'Specifies the Realized % for CO2 for Sustainability Goal';
                }
                field("Realized % for CH4"; Rec."Realized % for CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for CH4';
                    ToolTip = 'Specifies the Realized % for CH4 for Sustainability Goal';
                }
                field("Realized % for N2O"; Rec."Realized % for N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for N2O';
                    ToolTip = 'Specifies the Realized % for N2O for Sustainability Goal';
                }
                field("CO2 % vs Baseline"; Rec."CO2 % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CO2 % vs Baseline';
                    ToolTip = 'Specifies the CO2 % vs Baseline for Sustainability Goal';
                }
                field("CH4 % vs Baseline"; Rec."CH4 % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CH4 % vs Baseline';
                    ToolTip = 'Specifies the CH4 % vs Baseline for Sustainability Goal';
                }
                field("N2O % vs Baseline"; Rec."N2O % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'N2O % vs Baseline';
                    ToolTip = 'Specifies the N2O % vs Baseline for Sustainability Goal';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Refresh Now")
            {
                ApplicationArea = All;
                Caption = 'Refresh Now';
                ToolTip = 'Refresh the cues for Sustainability Goals';
                Image = Refresh;

                trigger OnAction()
                begin
                    ComputeSustGoalCue.SetCalledFromManualRefresh(true);
                    ComputeSustGoalCue.GetLatestSustainabilityGoalCue(Rec);
                    ComputeSustGoalCue.SetCalledFromManualRefresh(false);

                    CurrPage.Update(true);
                end;
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