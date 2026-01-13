// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Account;

codeunit 6295 "Sust. Emission Suggestion"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure BuildFromLines(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
        SustainabilityJnlLine.ReadIsolation(IsolationLevel::ReadCommitted);
        SustainabilityJnlLine.SetFilter("Account No.", '<>%1', '');
        SustainabilityJnlLine.SetFilter("Account Name", '<>%1', '');
        SustainabilityJnlLine.SetFilter(Description, '<>%1', '');
        if SustainabilityJnlLine.FindSet() then
            repeat
                InsertSustainEmissionSuggestion(SustainabilityJnlLine, SustainEmissionSuggestion);
                if CheckSustJnlLine(SustainEmissionSuggestion) then
                    SustainEmissionSuggestion.Mark(true);
            until SustainabilityJnlLine.Next() = 0;
        SustainEmissionSuggestion.MarkedOnly(true);
    end;

    procedure InsertSustainEmissionSuggestion(var SustainJnlLine: Record "Sustainability Jnl. Line"; var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    begin
        SustainEmissionSuggestion.Init();
        SustainEmissionSuggestion."Journal Template Name" := SustainJnlLine."Journal Template Name";
        SustainEmissionSuggestion."Journal Batch Name" := SustainJnlLine."Journal Batch Name";
        SustainEmissionSuggestion."Line No." := SustainJnlLine."Line No.";
        SustainEmissionSuggestion."Account No." := SustainJnlLine."Account No.";
        SustainEmissionSuggestion."Account Name" := SustainJnlLine."Account Name";
        SustainEmissionSuggestion."Account Category" := SustainJnlLine."Account Category";
        SustainEmissionSuggestion."Account Subcategory" := SustainJnlLine."Account Subcategory";
        SustainEmissionSuggestion.Description := SustainJnlLine.Description;
        SustainEmissionSuggestion."Emission CO2" := SustainJnlLine."Emission CO2";
        SustainEmissionSuggestion.Distance := SustainJnlLine.Distance;
        SustainEmissionSuggestion."Fuel/Electricity" := SustainJnlLine."Fuel/Electricity";
        SustainEmissionSuggestion."Country/Region Code" := SustainJnlLine."Country/Region Code";
        SustainEmissionSuggestion."Unit of Measure" := SustainJnlLine."Unit of Measure";
        SustainEmissionSuggestion."Installation Multiplier" := SustainJnlLine."Installation Multiplier";
        SustainEmissionSuggestion."Time Factor" := SustainJnlLine."Time Factor";
        SustainEmissionSuggestion."Custom Amount" := SustainJnlLine."Custom Amount";
        InsertEmissionFactorCO2(SustainEmissionSuggestion);
        InsertDataFromAccountCategory(SustainEmissionSuggestion);
        SustainEmissionSuggestion.Insert();
    end;

    procedure SustainEmissionSuggestionClearData(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    begin
        SustainEmissionSuggestion."Emission Factor Source" := '';
        SustainEmissionSuggestion."Emission Factor CO2" := 0;
        SustainEmissionSuggestion."Emission CO2" := 0;
        Clear(SustainEmissionSuggestion."Emission Calc. Explanation");
        Clear(SustainEmissionSuggestion."Emission Formula Json");
        SustainEmissionSuggestion."Calculated by Copilot" := false;
        SustainEmissionSuggestion."Raw Formula" := '';
        SustainEmissionSuggestion."Factor Taken From Source" := false;
        SustainEmissionSuggestion."No. of Warnings" := 0;
        SustainEmissionSuggestion."Warning Text" := '';
        SustainEmissionSuggestion."Warning Confidence" := 0;
        SustainEmissionSuggestion.Modify();
    end;

    local procedure InsertEmissionFactorCO2(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if not SustainAccountSubcategory.Get(SustainEmissionSuggestion."Account Category", SustainEmissionSuggestion."Account Subcategory") then
            exit;

        SustainEmissionSuggestion."Emission Factor CO2" := SustainAccountSubcategory."Emission Factor CO2";
    end;

    local procedure InsertDataFromAccountCategory(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    var
        SustainAccountCategory: Record "Sustain. Account Category";
    begin
        if not SustainAccountCategory.Get(SustainEmissionSuggestion."Account Category") then
            exit;

        SustainEmissionSuggestion."Accept Emission Factor" := not SustainAccountCategory."Do Not Calc. Emiss. Factor";
        SustainEmissionSuggestion."Exclude From Copilot" := SustainAccountCategory."Exclude From Copilot";
    end;

    local procedure CheckSustJnlLine(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"): Boolean
    begin
        if SustainEmissionSuggestion."Emission CO2" <> 0 then
            exit(false);

        if SustainEmissionSuggestion."Emission Factor CO2" <> 0 then
            exit(false);

        exit(CheckSustainEmissionSuggestion(SustainEmissionSuggestion));
    end;

    procedure CheckSustainEmissionSuggestion(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"): Boolean
    begin
        if not CheckSustCategory(SustainEmissionSuggestion) then
            exit(false);

        exit(CheckSustSubcategory(SustainEmissionSuggestion));
    end;

    local procedure CheckSustCategory(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"): Boolean
    var
        SustainAccountCategory: Record "Sustain. Account Category";
    begin
        if SustainEmissionSuggestion."Account Category" = '' then
            exit(false);

        if not SustainAccountCategory.Get(SustainEmissionSuggestion."Account Category") then
            exit(false);

        if SustainAccountCategory."Exclude From Copilot" then
            exit(false);

        if (SustainAccountCategory."Emission Scope" <> SustainAccountCategory."Emission Scope"::"Scope 1") and
           (SustainAccountCategory."Emission Scope" <> SustainAccountCategory."Emission Scope"::"Scope 2") and
           (SustainAccountCategory."Emission Scope" <> SustainAccountCategory."Emission Scope"::"Scope 3") and
           (SustainAccountCategory."Emission Scope" <> SustainAccountCategory."Emission Scope"::"Out of Scope") then
            exit(false);

        exit(SustainAccountCategory.CO2);
    end;

    local procedure CheckSustSubcategory(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"): Boolean
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if SustainEmissionSuggestion."Account Category" = '' then
            exit(false);

        if SustainEmissionSuggestion."Account Subcategory" = '' then
            exit(false);

        if not SustainAccountSubcategory.Get(SustainEmissionSuggestion."Account Category", SustainEmissionSuggestion."Account Subcategory") then
            exit(false);

        exit(SustainAccountSubcategory."Emission Factor CO2" = 0);
    end;
}