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
                    StyleExpr = RealizedPerForCO2StyleText;
                    ToolTip = 'Specifies the Realized % for CO2 for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
                }
                field("Realized % for CH4"; Rec."Realized % for CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for CH4';
                    StyleExpr = RealizedPerForCH4StyleText;
                    ToolTip = 'Specifies the Realized % for CH4 for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
                }
                field("Realized % for N2O"; Rec."Realized % for N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for N2O';
                    StyleExpr = RealizedPerForN2OStyleText;
                    ToolTip = 'Specifies the Realized % for N2O for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
                }
                field("CO2 % vs Baseline"; Rec."CO2 % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CO2 % vs Baseline';
                    StyleExpr = BaselinePerVsCO2StyleText;
                    ToolTip = 'Specifies the CO2 % vs Baseline for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
                }
                field("CH4 % vs Baseline"; Rec."CH4 % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CH4 % vs Baseline';
                    StyleExpr = BaselinePerVsCH4StyleText;
                    ToolTip = 'Specifies the CH4 % vs Baseline for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
                }
                field("N2O % vs Baseline"; Rec."N2O % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'N2O % vs Baseline';
                    StyleExpr = BaselinePerVsN2OStyleText;
                    ToolTip = 'Specifies the N2O % vs Baseline for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
                }
                field("Realized % for Water"; Rec."Realized % for Water")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for Water';
                    StyleExpr = RealizedPerForWaterStyleText;
                    ToolTip = 'Specifies the Realized % for Water for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
                }
                field("Realized % for Waste"; Rec."Realized % for Waste")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized % for Waste';
                    StyleExpr = RealizedPerForWasteStyleText;
                    ToolTip = 'Specifies the Realized % for Waste for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
                }
                field("Water % vs Baseline"; Rec."Water % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Water % vs Baseline';
                    StyleExpr = BaselinePerVsWaterStyleText;
                    ToolTip = 'Specifies the Water % vs Baseline for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
                }
                field("Waste % vs Baseline"; Rec."Waste % vs Baseline")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Waste % vs Baseline';
                    StyleExpr = BaselinePerVsWasteStyleText;
                    ToolTip = 'Specifies the NWaste2O % vs Baseline for Sustainability Goal';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMainSustainabilityGoal();
                    end;
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
        SetControlAppearance();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ComputeSustGoalCue.GetLatestSustainabilityGoalCue(Rec);
        SetControlAppearance();
    end;

    trigger OnAfterGetRecord()
    begin
        ComputeSustGoalCue.GetLatestSustainabilityGoalCue(Rec);
        SetControlAppearance();
    end;

    var
        ComputeSustGoalCue: Codeunit "Compute Sust. Goal Cue";
        SustainabilityChartMgmt: Codeunit "Sustainability Chart Mgmt.";
        BaselinePerVsCO2StyleText, BaselinePerVsCH4StyleText, BaselinePerVsN2OStyleText, BaselinePerVsWaterStyleText, BaselinePerVsWasteStyleText : Text;
        RealizedPerForCO2StyleText, RealizedPerForCH4StyleText, RealizedPerForN2OStyleText, RealizedPerForWaterStyleText, RealizedPerForWasteStyleText : Text;

    local procedure SetControlAppearance()
    begin
        BaselinePerVsCO2StyleText := Rec.GetBaselinePerVsEmissionStyle(SustainabilityChartMgmt.GetCO2(), Rec."CO2 % vs Baseline");
        BaselinePerVsCH4StyleText := Rec.GetBaselinePerVsEmissionStyle(SustainabilityChartMgmt.GetCH4(), Rec."CH4 % vs Baseline");
        BaselinePerVsN2OStyleText := Rec.GetBaselinePerVsEmissionStyle(SustainabilityChartMgmt.GetN2O(), Rec."N2O % vs Baseline");
        BaselinePerVsWaterStyleText := Rec.GetBaselinePerVsEmissionStyle(SustainabilityChartMgmt.GetWater(), Rec."Water % vs Baseline");
        BaselinePerVsWasteStyleText := Rec.GetBaselinePerVsEmissionStyle(SustainabilityChartMgmt.GetWaste(), Rec."Waste % vs Baseline");

        RealizedPerForCO2StyleText := Rec.GetRealizedPerForEmissionStyle(SustainabilityChartMgmt.GetCO2(), Rec."Realized % for CO2");
        RealizedPerForCH4StyleText := Rec.GetRealizedPerForEmissionStyle(SustainabilityChartMgmt.GetCH4(), Rec."Realized % for CH4");
        RealizedPerForN2OStyleText := Rec.GetRealizedPerForEmissionStyle(SustainabilityChartMgmt.GetN2O(), Rec."Realized % for N2O");
        RealizedPerForWaterStyleText := Rec.GetRealizedPerForEmissionStyle(SustainabilityChartMgmt.GetWater(), Rec."Realized % for Water");
        RealizedPerForWasteStyleText := Rec.GetRealizedPerForEmissionStyle(SustainabilityChartMgmt.GetWaste(), Rec."Realized % for Waste");
    end;
}