// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Journal;

page 6329 "Sustain. Emission Suggestion"
{
    Caption = 'Sustainability Emission Suggestion';
    PageType = PromptDialog;
    IsPreview = true;
    Extensible = false;
    ApplicationArea = All;
    Editable = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            group(SustainabilityJournalHeader)
            {
                ShowCaption = false;

                field("Lines suggested Automatically"; AutoSuggestedLinesTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Auto-suggested';
                    Editable = false;
                    ToolTip = 'Specifies the number of suggested lines proposed automatically';
                }
                field("Lines suggested by Copilot"; CopilotSuggestedLinesTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Copilot suggested';
                    Editable = false;
                    ToolTip = 'Specifies the number of suggested lines proposed by Copilot';

                    trigger OnDrillDown()
                    var
                        SustainEmissionSuggestion: Record "Sustain. Emission Suggestion";
                        SustEmisSuggestionList: Page "Sust. Emis. Suggestion List";
                    begin
                        if NumberOfCopilotSuggestedLines = 0 then
                            exit;

                        SustainEmissionSuggestion.Copy(SustainEmissionSuggestionGlobal, true);
                        SustainEmissionSuggestion.SetRange("Calculated by Copilot", true);
                        SustEmisSuggestionList.Load(SustainEmissionSuggestion);
                        SustEmisSuggestionList.SetTableView(SustainEmissionSuggestion);
                        SustEmisSuggestionList.RunModal();
                        SustEmisSuggestionList.GetRecord(SustainEmissionSuggestion);
                        SustainEmissionSuggestionGlobal.Copy(SustainEmissionSuggestion, true);
                        if SustEmisSuggestionList.GetPageUpdated() then
                            GenerateCopilotSuggestion();
                        CurrPage.Update();
                    end;
                }
                field("Excluded from Suggestions"; ExcludedFromSuggestionTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Excluded from suggestions';
                    Editable = false;
                    ToolTip = 'Specifies the number of sustainability lines excluded from suggestions based on sustainability account category';
                }
                field("Summary Text"; SummaryTxt)
                {
                    ApplicationArea = All;
                    Caption = '';
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = SummaryStyleTxt;
                    ToolTip = 'Specifies the matching summary';
                }
                field("Total Journal Confidence"; TotalJournalConfidenceTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Total Journal Confidence';
                    Editable = false;
                    ToolTip = 'Specifies confidence calculated based on warnings. If there is no warning in the line this is 100% confidence and using lower confidence amount if we have warning';
                }
            }
            part(SustEmisSuggestionSubpage; "Sust. Emis. Suggestion Subpage")
            {
                Caption = 'Match proposals';
                ShowFilter = false;
                ApplicationArea = All;
                Editable = true;
                Enabled = true;
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                Tooltip = 'Generate a suggestion based on the input prompt';
                trigger OnAction()
                var
                    SustEmissionSuggestion: Codeunit "Sust. Emission Suggestion";
                begin
                    SustEmissionSuggestion.BuildFromLines(SustainEmissionSuggestionGlobal, SustainabilityJnlLineGlobal);
                    GenerateCopilotSuggestion();
                end;
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                Tooltip = 'Regenerate a suggestion based on the input prompt';
                trigger OnAction()
                begin
                    GenerateCopilotSuggestion();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Keep it';
                ToolTip = 'Save sustainability line matching proposed by Copilot.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard it';
                ToolTip = 'Discard sustainability line matching proposed by Copilot.';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateHeaderData(SustainEmissionSuggestionGlobal);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::OK then
            CurrPage.SustEmisSuggestionSubpage.Page.ProcessKeep();
    end;

    internal procedure Load(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    begin
        CurrPage.SustEmisSuggestionSubpage.Page.Load(SustainEmissionSuggestion);
    end;

    internal procedure Load(var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer")
    begin
        CurrPage.SustEmisSuggestionSubpage.Page.Load(SourceCO2EmissionBuffer);
    end;

    internal procedure GenerateCopilotSuggestion()
    var
        SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer";
        SustainabilityAI: Codeunit "Sustainability AI";
    begin
        SustainabilityAI.AICall(SustainEmissionSuggestionGlobal, SourceCO2EmissionBuffer);
        Load(SustainEmissionSuggestionGlobal);
        Load(SourceCO2EmissionBuffer);
        if CopilotMatchExist() then
            SetPromptMode(PromptMode::Content);
    end;

    internal procedure SetPromptMode(PromptMode: PromptMode)
    begin
        CurrPage.PromptMode := PromptMode;
    end;

    internal procedure UpdateHeaderData(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    var
        Percent: Decimal;
        NumberSustainabilityLines, NumberOfExcludedFromSuggestionLines : Integer;
        AllLinesMatchedTxt: Label 'All lines (100%) are matched. Review match proposals.';
        TotalJournalConfidenceLbl: Label '%1%', Comment = '%1 - a decimal between 0 and 100';
        AutoSuggestedLinesLbl: Label '%1 of %2 lines (%3%)', Comment = '%1 - an integer; %2 - an integer; %3 a decimal between 0 and 100';
        SubsetOfLinesMatchedTxt: label '%1% of lines are matched. Review match proposals.', Comment = '%1 - a decimal between 0 and 100';
    begin
        SustainEmissionSuggestion.Reset();
        NumberSustainabilityLines := SustainEmissionSuggestion.Count();
        NumberOfAutoSuggestedLines := CalculateAutoSuggestedLines(SustainEmissionSuggestion);
        NumberOfCopilotSuggestedLines := CalculateCopilotSuggestedLines(SustainEmissionSuggestion);
        NumberOfExcludedFromSuggestionLines := CalculateExcludedFromSuggestionLines(SustainEmissionSuggestion);
        SustainEmissionSuggestion.Reset();

        if NumberOfAutoSuggestedLines = 0 then
            Percent := 0
        else
            Percent := Round((NumberOfAutoSuggestedLines / NumberSustainabilityLines) * 100, 0.1);
        AutoSuggestedLinesTxt := StrSubstNo(AutoSuggestedLinesLbl, NumberOfAutoSuggestedLines, NumberSustainabilityLines, Percent);

        if NumberOfCopilotSuggestedLines = 0 then
            Percent := 0
        else
            Percent := Round((NumberOfCopilotSuggestedLines / NumberSustainabilityLines) * 100, 0.1);
        CopilotSuggestedLinesTxt := StrSubstNo(AutoSuggestedLinesLbl, NumberOfCopilotSuggestedLines, NumberSustainabilityLines, Percent);

        if NumberOfExcludedFromSuggestionLines = 0 then
            Percent := 0
        else
            Percent := Round((NumberOfExcludedFromSuggestionLines / NumberSustainabilityLines) * 100, 0.1);
        ExcludedFromSuggestionTxt := StrSubstNo(AutoSuggestedLinesLbl, NumberOfExcludedFromSuggestionLines, NumberSustainabilityLines, Percent);

        TotalJournalConfidenceTxt := StrSubstNo(TotalJournalConfidenceLbl, CalculateTotalConfidence(SustainEmissionSuggestion));
        if NumberSustainabilityLines <= (NumberOfAutoSuggestedLines + NumberOfCopilotSuggestedLines + NumberOfExcludedFromSuggestionLines) then begin
            SummaryStyleTxt := 'Favorable';
            SummaryTxt := AllLinesMatchedTxt;
        end else begin
            Percent := Round(((NumberOfAutoSuggestedLines + NumberOfCopilotSuggestedLines + NumberOfExcludedFromSuggestionLines) / NumberSustainabilityLines) * 100, 0.1);
            SummaryStyleTxt := 'Ambiguous';
            SummaryTxt := StrSubstNo(SubsetOfLinesMatchedTxt, Percent);
        end;
    end;

    internal procedure SetData(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    begin
        SustainabilityJnlLineGlobal.Copy(SustainabilityJnlLine);
        SustainEmissionSuggestionGlobal.Copy(SustainEmissionSuggestion, true);
    end;

    local procedure CalculateTotalConfidence(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"): Decimal
    var
        CopilotSuggestedLinesConfidence: Decimal;
    begin
        if NumberOfCopilotSuggestedLines + NumberOfAutoSuggestedLines = 0 then
            exit(0);
        CopilotSuggestedLinesConfidence := CalculateCopilotSuggestedLinesWithWarnings(SustainEmissionSuggestion);

        exit(Round((100 * NumberOfAutoSuggestedLines + CopilotSuggestedLinesConfidence) / (NumberOfAutoSuggestedLines + NumberOfCopilotSuggestedLines)));
    end;

    local procedure CalculateAutoSuggestedLines(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion") AutoSuggestedLines: Integer
    begin
        AutoSuggestedLines := 0;
        SustainEmissionSuggestion.Reset();
        SustainEmissionSuggestion.SetRange("Calculated by Copilot", false);
        if SustainEmissionSuggestion.FindSet() then
            repeat
                if (SustainEmissionSuggestion."Emission Factor CO2" > 0) or (SustainEmissionSuggestion."Emission CO2" > 0) then
                    AutoSuggestedLines += 1;
            until SustainEmissionSuggestion.Next() = 0;

        exit(AutoSuggestedLines);
    end;

    local procedure CalculateCopilotSuggestedLines(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"): Integer
    begin
        SustainEmissionSuggestion.Reset();
        SustainEmissionSuggestion.SetRange("Calculated by Copilot", true);
        exit(SustainEmissionSuggestion.Count());
    end;

    local procedure CalculateExcludedFromSuggestionLines(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"): Integer
    begin
        SustainEmissionSuggestion.Reset();
        SustainEmissionSuggestion.SetRange("Exclude From Copilot", true);
        SustainEmissionSuggestion.SetRange("Emission CO2", 0);
        SustainEmissionSuggestion.SetRange("Emission Factor CO2", 0);
        exit(SustainEmissionSuggestion.Count());
    end;

    local procedure CalculateCopilotSuggestedLinesWithWarnings(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"): Decimal
    begin
        SustainEmissionSuggestion.Reset();
        SustainEmissionSuggestion.SetRange("Calculated by Copilot", true);
        SustainEmissionSuggestion.CalcSums("Warning Confidence");
        exit(SustainEmissionSuggestion."Warning Confidence");
    end;

    local procedure CopilotMatchExist(): Boolean
    begin
        exit(NumberOfCopilotSuggestedLines + NumberOfAutoSuggestedLines > 0);
    end;

    var
        SustainabilityJnlLineGlobal: Record "Sustainability Jnl. Line";
        SustainEmissionSuggestionGlobal: Record "Sustain. Emission Suggestion";
        NumberOfCopilotSuggestedLines, NumberOfAutoSuggestedLines : Integer;
        AutoSuggestedLinesTxt, CopilotSuggestedLinesTxt, ExcludedFromSuggestionTxt, TotalJournalConfidenceTxt : Text;
        SummaryTxt, SummaryStyleTxt : Text;
}
