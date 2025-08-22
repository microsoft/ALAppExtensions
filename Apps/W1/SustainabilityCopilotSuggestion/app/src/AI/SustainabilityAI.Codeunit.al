// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Foundation.UOM;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;
using System.AI;
using Microsoft.Sustainability.Account;
using System.Telemetry;

codeunit 6299 "Sustainability AI"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Telemetry: Codeunit Telemetry;
        DistanceUserInputTxt: Label 'Input: I am based in the %1, and I travel by the %2 %3 for %4 %5', Comment = '%1 = Country, %2 = category name, %3 = account name, %4 = unit of measure name, %5 = unit spent';
        FuelElectricityInputTxt: Label 'Input: I am based in the %1, used the %2 %3, consuming %4 %5 as an energy.', Comment = '%1 = Country, %2 = category name, %3 = account name, %4 = unit of measure name, %5 = unit spent';
        CustomUserInputTxt: Label 'Input: I used %1 %2 for %3 %4', Comment = '%1 = category name, %2 = account name, %3 = unit spent, %4 = unit of measure name';
        LeakageInputTxt: Label 'Input: I am based in the %1 and used %2 %3 working used capacity %4 %5 with annual leak rate %6% and used for %7% of a time.', Comment = '%1 = Country, %2 = category name, %3 = account name, %4 = unit spent, %5 = unit of measure name, %6 = leak rate, %7 = time used';
        UnsupportedCalculationFoundationLbl: Label 'Unsupported Calculation Foundation';
        FormulaApplicationTxt: Label 'Formula application', Locked = true;
        FormulaAppliedTxt: Label 'Formula is applied for line %1', Comment = '%1 = line no.', Locked = true;
        FormulaNotAppliedTxt: Label 'Formula is not applied for line %1', Comment = '%1 = line no.', Locked = true;
        GeneratingUserMessageForLinesTxt: Label 'Generating user message for lines given line filter =  %1. Count of lines = %2', Locked = true, Comment = '%1 = line filter, %2 = count of lines';
        LineExcludedFromUserMessageTxt: Label 'Sustainability emission suggestion line %1 is excluded from user message', Comment = '%1 = line number', Locked = true;

    [NonDebuggable]
    internal procedure AICall(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        SustainabilityFormula: Codeunit "Sustainability Formula";
        SustEmisSuggestionImpl: Codeunit "Sust. Emis. Suggestion Impl.";
        UserMessage: Text;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sustainability Emission Suggestion") then
            exit;

        SourceCO2EmissionBuffer.Reset();
        SourceCO2EmissionBuffer.DeleteAll();

        GenerateUserMessageForAllLines(SustainEmissionSuggestion, UserMessage, true, false);
        if UserMessage = '' then
            exit;
        AICall(SustainEmissionSuggestion, SourceCO2EmissionBuffer, UserMessage);
        SustainEmissionSuggestion.Reset();
        if SustainEmissionSuggestion.FindSet() then begin
            repeat
                if SustainabilityFormula.ApplyFormula(SustainEmissionSuggestion, SourceCO2EmissionBuffer) then
                    Telemetry.LogMessage(FormulaApplicationTxt, StrSubstNo(FormulaAppliedTxt, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata)
                else
                    Telemetry.LogMessage(FormulaApplicationTxt, StrSubstNo(FormulaNotAppliedTxt, SustainEmissionSuggestion."Line No."), Verbosity::Error, DataClassification::SystemMetadata);
            until SustainEmissionSuggestion.Next() = 0;
            SustainEmissionSuggestion.FindSet();
        end;
        FeatureTelemetry.LogUptake('0000PVS', SustEmisSuggestionImpl.GetFeatureName(), "Feature Uptake Status"::Used);
    end;

    internal procedure AICall(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; UserMessage: Text): Text
    var
        SustainabilityChatCompletion: Codeunit "Sustainability Chat Completion";
        SuggestionsToHandle: Integer;
        LastHandledLineNo: Integer;
    begin
        SustainabilityChatCompletion.GenerateRawFormulaChatCompletion(SustainEmissionSuggestion, UserMessage);
        SustainEmissionSuggestion.Reset();
        SustainEmissionSuggestion.FindSet();
        SuggestionsToHandle := 0;
        LastHandledLineNo := 0;
        repeat
            SuggestionsToHandle += 1;
            if SuggestionsToHandle > MaxNumberOfLinesInBatch() then begin
                AICallForFilteredLines(SustainEmissionSuggestion, SourceCO2EmissionBuffer, LastHandledLineNo, UserMessage);
                SuggestionsToHandle := 0;
            end;
        until SustainEmissionSuggestion.Next() = 0;
        if SuggestionsToHandle > 0 then
            AICallForFilteredLines(SustainEmissionSuggestion, SourceCO2EmissionBuffer, LastHandledLineNo, UserMessage);
    end;

    internal procedure AICallForFilteredLines(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; var LastHandledLineNo: Integer; UserMessage: Text)
    var
        SustainabilityChatCompletion: Codeunit "Sustainability Chat Completion";
        LastLineNo, NextLineNoToHandle : Integer;
    begin
        LastLineNo := SustainEmissionSuggestion."Line No.";
        NextLineNoToHandle := LastHandledLineNo + 1;
        if NextLineNoToHandle > SustainEmissionSuggestion."Line No." then
            NextLineNoToHandle := SustainEmissionSuggestion."Line No.";
        SustainEmissionSuggestion.SetRange("Line No.", NextLineNoToHandle, SustainEmissionSuggestion."Line No.");
        if not GenerateUserMessageForFilteredLines(SustainEmissionSuggestion, UserMessage, false, true) then begin
            SustainEmissionSuggestion.SetRange("Line No.");
            Telemetry.LogMessage('0000PVT', 'No user message generated for filtered lines', Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        SustainabilityChatCompletion.GenerateFormulaBreakdownChatCompletion(SustainEmissionSuggestion, UserMessage);
        SustainEmissionSuggestion.SetRange("Line No.");
        MatchCategoryToInput(SustainEmissionSuggestion, SourceCO2EmissionBuffer);
        SustainEmissionSuggestion.SetRange("Line No.");
        LastHandledLineNo := LastLineNo;
    end;

    internal procedure MatchCategoryToInput(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer")
    var
        SourceCO2Emission: Record "Source CO2 Emission";
        SustainabilityChatCompletion: Codeunit "Sustainability Chat Completion";
        UserMessage: Text;
    begin
        SourceCO2Emission.ReadIsolation(IsolationLevel::ReadCommitted);
        SourceCO2Emission.SetFilter("Starting Date", '<=%1', WorkDate());
        SourceCO2Emission.SetFilter("Ending Date", '>=%1|%2', WorkDate(), 0D);
        if SourceCO2Emission.IsEmpty() then begin
            Telemetry.LogMessage('0000PVU', 'Source CO2 Emission is empty, skipping match category to input', Verbosity::Normal, DataClassification::SystemMetadata);
            exit;
        end;

        if not GenerateUserMessageForAllLines(SustainEmissionSuggestion, UserMessage, false, false) then begin
            Telemetry.LogMessage('0000PVV', 'No user message generated for all lines', Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        UserMessage += '\n';
        AddSourceCO2EmissionToUserMessage(UserMessage, SourceCO2Emission);
        SustainabilityChatCompletion.GenerateMatchCategoryToInputChatCompletion(SustainEmissionSuggestion, SourceCO2EmissionBuffer, UserMessage);
    end;

    local procedure GenerateUserMessageForAllLines(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var UserMessage: Text; ShallInsertWarnings: Boolean; AddFormula: Boolean): Boolean
    begin
        SustainEmissionSuggestion.SetRange("Line No.");
        exit(GenerateUserMessageForFilteredLines(SustainEmissionSuggestion, UserMessage, ShallInsertWarnings, AddFormula));
    end;

    local procedure GenerateUserMessageForFilteredLines(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var UserMessage: Text; ShallInsertWarnings: Boolean; AddFormula: Boolean) UserMessageGenerated: Boolean
    begin
        UserMessage := '';
        if SustainEmissionSuggestion.FindSet() then
            repeat
                UserMessageGenerated := UserMessageGenerated or GenerateUserMessage(SustainEmissionSuggestion, UserMessage, ShallInsertWarnings, AddFormula);
            until SustainEmissionSuggestion.Next() = 0;

        Telemetry.LogMessage('0000PVW', StrSubstNo(GeneratingUserMessageForLinesTxt, SustainEmissionSuggestion.GetFilter("Line No."), SustainEmissionSuggestion.CountApprox), Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    local procedure GenerateUserMessage(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var UserMessage: Text; ShallInsertWarnings: Boolean; AddFormula: Boolean): Boolean
    var
        SustainAccountCategory: Record "Sustain. Account Category";
        UnitOfMeasure: Record "Unit of Measure";
        SustEmissSuggestionWarning: Codeunit "Sust. Emiss.Suggestion Warning";
        UnitOfMeasureText: Text;
        CannotAddBlankRawFormulaLbl: Label 'Cannot add blank raw formula to user message for line %1', Comment = '%1 = line number', Locked = true;
    begin
        if AddFormula and (SustainEmissionSuggestion."Raw Formula" = '') then begin
            Telemetry.LogMessage('0000PVX', StrSubstNo(CannotAddBlankRawFormulaLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
            exit(false);
        end;
        if ShallInsertWarnings then
            SustEmissSuggestionWarning.InsertWarnings(SustainEmissionSuggestion);
        if SustainEmissionSuggestion."Exclude From User Message" then begin
            Telemetry.LogMessage('0000PVY', StrSubstNo(LineExcludedFromUserMessageTxt, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
            exit(false);
        end;

        if UnitOfMeasure.Get(SustainEmissionSuggestion."Unit of Measure") then
            UnitOfMeasureText := UnitOfMeasure.GetDescriptionInCurrentLanguage()
        else
            UnitOfMeasureText := '';
        if UserMessage <> '' then
            UserMessage += '\n';
        SustainAccountCategory.Get(SustainEmissionSuggestion."Account Category");
        case SustainAccountCategory."Calculation Foundation" of
            SustainAccountCategory."Calculation Foundation"::Distance:
                UserMessage += StrSubstNo(DistanceUserInputTxt, GetCountryRegion(SustainEmissionSuggestion."Country/Region Code"), SustainEmissionSuggestion."Account Name", SustainEmissionSuggestion.Description, Format(SustainEmissionSuggestion.Distance), UnitOfMeasureText);
            SustainAccountCategory."Calculation Foundation"::"Fuel/Electricity":
                UserMessage += StrSubstNo(FuelElectricityInputTxt, GetCountryRegion(SustainEmissionSuggestion."Country/Region Code"), SustainEmissionSuggestion."Account Name", SustainEmissionSuggestion.Description, Format(SustainEmissionSuggestion."Fuel/Electricity"), UnitOfMeasureText);
            SustainAccountCategory."Calculation Foundation"::Custom:
                UserMessage += StrSubstNo(CustomUserInputTxt, SustainEmissionSuggestion."Account Name", SustainEmissionSuggestion.Description, Format(SustainEmissionSuggestion."Custom Amount"), UnitOfMeasureText);
            SustainAccountCategory."Calculation Foundation"::Installations:
                UserMessage += StrSubstNo(LeakageInputTxt, GetCountryRegion(SustainEmissionSuggestion."Country/Region Code"), SustainEmissionSuggestion."Account Name", SustainEmissionSuggestion.Description, Format(SustainEmissionSuggestion."Fuel/Electricity"), UnitOfMeasureText, Format(SustainEmissionSuggestion."Custom Amount" * 100), Format(SustainEmissionSuggestion."Time Factor" * 100));
            else begin
                SustainEmissionSuggestion."Calculated by Copilot" := false;
                SustainEmissionSuggestion.UpdateWarnings(UnsupportedCalculationFoundationLbl);
                SustainEmissionSuggestion.Modify();
                Telemetry.LogMessage('0000PVZ', UnsupportedCalculationFoundationLbl, Verbosity::Normal, DataClassification::SystemMetadata);
                exit(false);
            end;
        end;
        if AddFormula and (SustainEmissionSuggestion."Raw Formula" <> '') then
            UserMessage += ';Formula:' + SustainEmissionSuggestion."Raw Formula";
        UserMessage += ';Line No.:' + Format(SustainEmissionSuggestion."Line No.");
        exit(true);
    end;

    local procedure AddSourceCO2EmissionToUserMessage(var UserMessage: Text; var SourceCO2Emission: Record "Source CO2 Emission")
    var
        SourceCO2EmissionCategoriesAddedToUserMessageLbl: Label 'Source CO2 Emission categories added to user message. Count of sources = %1', Comment = '%1 = count of sources', Locked = true;
    begin
        if UserMessage <> '' then
            UserMessage += '\n\n';
        UserMessage += 'Categories:';
        SourceCO2Emission.SetRange("Line No.");
        if SourceCO2Emission.FindSet() then
            repeat
                UserMessage += 'CategoryId:' + Format(SourceCO2Emission.Id) + ';Category:' + Format(SourceCO2Emission.Description) + '\n';
            until SourceCO2Emission.Next() = 0;
        Telemetry.LogMessage('0000PW0', StrSubstNo(SourceCO2EmissionCategoriesAddedToUserMessageLbl, SourceCO2Emission.CountApprox), Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    local procedure GetCountryRegion(CountryRegionCode: Code[10]): Text
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        if CountryRegionCode = '' then begin
            CompanyInformation.Get();
            CountryRegionCode := CompanyInformation.GetCompanyCountryRegionCode();
        end;

        if CountryRegionCode = '' then
            exit;

        CountryRegion.Get(CountryRegionCode);

        exit(CountryRegion.GetNameInCurrentLanguage());
    end;

    local procedure MaxNumberOfLinesInBatch(): Integer
    begin
        exit(40);
    end;
}