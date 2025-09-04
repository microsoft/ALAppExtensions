// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

page 6331 "Sust. Emis. Suggestion Subpage"
{
    Caption = 'Lines proposed by Copilot';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Sustain. Emission Suggestion";
    SourceTableTemporary = true;
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    InherentPermissions = X;
    InherentEntitlements = X;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Emission Factor Source"; Rec."Emission Factor Source")
                {
                    StyleExpr = StyleTxt;

                    trigger OnDrillDown()
                    begin
                        SelectEmission();
                    end;
                }
                field("Account Name"; Rec."Account Name")
                {
                    StyleExpr = StyleTxt;
                }
                field("Account Category"; Rec."Account Category")
                {
                    Visible = false;
                    StyleExpr = StyleTxt;
                }
                field(Description; Rec."Description")
                {
                    StyleExpr = StyleTxt;
                }
                field("Account Subcategory"; Rec."Account Subcategory")
                {
                    Visible = false;
                    StyleExpr = StyleTxt;
                }
                field("Emission CO2"; Rec."Emission CO2")
                {
                    Style = Strong;
                    StyleExpr = StyleTxt;
                }
                field("No. of Warnings"; Rec."No. of Warnings")
                {
                    StyleExpr = StyleTxt;

                    trigger OnDrillDown()
                    var
                        SustainEmissionSuggestion: Record "Sustain. Emission Suggestion";
                        SustEmisSuggestionList: Page "Sust. Emis. Suggestion List";
                    begin
                        SustainEmissionSuggestion.Copy(Rec, true);
                        SustainEmissionSuggestion.SetRange("Line No.", Rec."Line No.");
                        SustEmisSuggestionList.SetWarningVisibility();
                        SustEmisSuggestionList.Load(SustainEmissionSuggestion);
                        SustEmisSuggestionList.SetTableView(SustainEmissionSuggestion);
                        SustEmisSuggestionList.RunModal();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleTxt := Rec.SetStyle();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    local procedure SelectEmission()
    var
        SustainabilityFormula: Codeunit "Sustainability Formula";
        SustEmissSuggestionWarning: Codeunit "Sust. Emiss.Suggestion Warning";
        SourceCO2EmissionList: Page "Source CO2 Emission List";
        NoOfSourceCO2EmissionBuffer: Integer;
    begin
        SourceCO2EmissionBuffer.SetRange("Line No.", Rec."Line No.");
        SourceCO2EmissionBuffer.SetFilter("Confidence Value", '>=%1', 0.8);
        NoOfSourceCO2EmissionBuffer := SourceCO2EmissionBuffer.Count();
        if NoOfSourceCO2EmissionBuffer = 0 then
            exit;
        if NoOfSourceCO2EmissionBuffer > 5 then
            Error('');

        SourceCO2EmissionList.Load(SourceCO2EmissionBuffer);
        SourceCO2EmissionList.LookupMode(true);
        if SourceCO2EmissionList.RunModal() = Action::LookupOK then begin
            SourceCO2EmissionList.GetRecord(SourceCO2EmissionBuffer);
            Rec."Emission Factor Source" := SourceCO2EmissionBuffer."Source Description" + ', ' + SourceCO2EmissionBuffer.Description;
            Rec."Emission Factor CO2" := SourceCO2EmissionBuffer."Emission Factor CO2";
            Rec."Factor Taken From Source" := true;
            SustEmissSuggestionWarning.ResetWarnings(Rec);
            SustainabilityFormula.ApplyFormula(Rec, SourceCO2EmissionBuffer);
            Rec.Modify();
            CurrPage.Update(false);
        end;
    end;

    procedure ProcessKeep()
    begin
        Rec.SetFilter("Emission CO2", '<>0');
        if Rec.FindSet() then
            repeat
                Rec.UpdateSustainabilityJournalLine();
                Rec.UpdateSubcategory();
            until Rec.Next() = 0;
    end;

    internal procedure Load(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    begin
        Rec.Copy(SustainEmissionSuggestion, true);
        Rec.Reset();
    end;

    internal procedure Load(var SourceCO2EmissionBufferFrom: Record "Source CO2 Emission Buffer")
    begin
        SourceCO2EmissionBuffer.Copy(SourceCO2EmissionBufferFrom, true);
        SourceCO2EmissionBuffer.Reset();
    end;

    internal procedure GetData(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    begin
        SustainEmissionSuggestion.Copy(Rec, true);
    end;

    var
        SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer";

        StyleTxt: Text;
}