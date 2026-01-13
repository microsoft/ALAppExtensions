// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Account;
using Microsoft.Foundation.Company;
using System.Telemetry;

codeunit 6333 "Sust. Emiss.Suggestion Warning"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Telemetry: Codeunit Telemetry;
        DistanceIsNotProvidedLbl: Label 'Distance is not provided';
        FuelElectricityIsNotProvidedLbl: Label 'Fuel/Electricity is not provided';
        TimeFactorIsNotProvidedLbl: Label 'Time Factor is not provided';
        CustomAmountIsNotProvidedLbl: Label 'Custom Amount is not provided';
        ZeroDistanceLbl: Label 'Distance is 0 for line %1', Comment = '%1 = line number', Locked = true;
        ZeroFuelElectricityLbl: Label 'Fuel/Electricity is 0 for line %1', Comment = '%1 = line number', Locked = true;
        ZeroTimeFactorLbl: Label 'Time Factor is 0 for line %1', Comment = '%1 = line number', Locked = true;
        ZeroCustomAmountLbl: Label 'Custom Amount is 0 for line %1', Comment = '%1 = line number', Locked = true;

    procedure InsertWarnings(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    var
        SustainabilityAccountCategory: Record "Sustain. Account Category";
    begin
        SustainEmissionSuggestion."Warning Text" := '';
        SustainEmissionSuggestion."No. of Warnings" := 0;
        SustainEmissionSuggestion."Warning Confidence" := 100;
        SustainabilityAccountCategory.Get(SustainEmissionSuggestion."Account Category");
        case SustainabilityAccountCategory."Calculation Foundation" of
            SustainabilityAccountCategory."Calculation Foundation"::Distance:
                if (SustainEmissionSuggestion.Distance = 0) then begin
                    SustainEmissionSuggestion.UpdateWarnings(DistanceIsNotProvidedLbl);
                    SustainEmissionSuggestion."Exclude From User Message" := true;
                    Telemetry.LogMessage('0000PWH', StrSubstNo(ZeroDistanceLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                end;
            SustainabilityAccountCategory."Calculation Foundation"::"Fuel/Electricity":
                if (SustainEmissionSuggestion."Fuel/Electricity" = 0) then begin
                    SustainEmissionSuggestion.UpdateWarnings(FuelElectricityIsNotProvidedLbl);
                    SustainEmissionSuggestion."Exclude From User Message" := true;
                    Telemetry.LogMessage('0000PWI', StrSubstNo(ZeroFuelElectricityLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                end;
            SustainabilityAccountCategory."Calculation Foundation"::Installations:
                begin
                    if (SustainEmissionSuggestion."Time Factor" = 0) then begin
                        SustainEmissionSuggestion.UpdateWarnings(TimeFactorIsNotProvidedLbl);
                        SustainEmissionSuggestion."Exclude From User Message" := true;
                        Telemetry.LogMessage('0000PWJ', StrSubstNo(ZeroTimeFactorLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                    end;
                    if (SustainEmissionSuggestion."Custom Amount" = 0) then begin
                        SustainEmissionSuggestion.UpdateWarnings(CustomAmountIsNotProvidedLbl);
                        SustainEmissionSuggestion."Exclude From User Message" := true;
                        Telemetry.LogMessage('0000PWK', StrSubstNo(ZeroCustomAmountLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                    end;
                end;
            SustainabilityAccountCategory."Calculation Foundation"::Custom:
                if (SustainEmissionSuggestion."Custom Amount" = 0) then begin
                    SustainEmissionSuggestion.UpdateWarnings(CustomAmountIsNotProvidedLbl);
                    SustainEmissionSuggestion."Exclude From User Message" := true;
                    Telemetry.LogMessage('0000PWL', StrSubstNo(ZeroCustomAmountLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                end;
        end;
        CheckCountryCode(SustainEmissionSuggestion);
        CheckUnitOfMeasure(SustainEmissionSuggestion, SustainabilityAccountCategory);
        SustainEmissionSuggestion.Modify();
    end;

    procedure ResetWarnings(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    begin
        SustainEmissionSuggestion."No. of Warnings" := 0;
        SustainEmissionSuggestion."Warning Text" := '';
        InsertWarnings(SustainEmissionSuggestion);
    end;

    local procedure CheckCountryCode(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    var
        CompanyInformation: Record "Company Information";
        CountryRegionCodeNotProvidedLbl: Label 'Country/Region Code is not provided';
    begin
        if SustainEmissionSuggestion."Country/Region Code" <> '' then
            exit;

        if SustainEmissionSuggestion."Country/Region Code" = '' then
            if CompanyInformation.GetCompanyCountryRegionCode() = '' then
                SustainEmissionSuggestion.UpdateWarnings(CountryRegionCodeNotProvidedLbl);
    end;

    local procedure CheckUnitOfMeasure(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SustainabilityAccountCategory: Record "Sustain. Account Category")
    var
        UnitOfMeasureWarningLbl: Label 'Unit of Measure is not provided';
    begin
        if SustainEmissionSuggestion."Unit of Measure" <> '' then
            exit;

        if SustainabilityAccountCategory."Calculation Foundation" <> SustainabilityAccountCategory."Calculation Foundation"::Custom then begin
            SustainEmissionSuggestion.UpdateWarnings(UnitOfMeasureWarningLbl);
            exit;
        end else
            if SustainabilityAccountCategory."Custom Value" = '' then
                SustainEmissionSuggestion.UpdateWarnings(UnitOfMeasureWarningLbl);
    end;
}