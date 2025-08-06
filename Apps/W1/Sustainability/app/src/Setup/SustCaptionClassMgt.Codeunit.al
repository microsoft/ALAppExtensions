// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Setup;

using System.Text;

codeunit 6278 "Sust. CaptionClass Mgt"
{
    trigger OnRun()
    begin
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        BalanceLbl: Label 'Balance (%1)', Comment = '%1 = Emission Type';
        NetChangeLbl: Label 'Net Change (%1)', Comment = '%1 = Emission Type';
        BalanceAtDateLbl: Label 'Balance at Date (%1)', Comment = '%1 = Emission Type';
        EmissionFactorLbl: Label 'Emission Factor %1', Comment = '%1 = Emission Type';
        EmissionLbl: Label 'Emission %1', Comment = '%1 = Emission Type';
        BaselineLbl: Label 'Baseline for %1', Comment = '%1 = Emission Type';
        CurrentValueLbl: Label 'Current Value for %1', Comment = '%1 = Emission Type';
        TargetValueLbl: Label 'Target Value for %1', Comment = '%1 = Emission Type';
        DefaultEmissionLbl: Label 'Default %1 Emission', Comment = '%1 = Emission Type';
        PostedEmissionLbl: Label 'Posted Emission %1', Comment = '%1 = Emission Type';
        TotalEmissionLbl: Label 'Total Emission %1', Comment = '%1 = Emission Type';
        TotalEmissionUnitOfMeasureLbl: Label 'Total Emission %1 (%2)', Comment = '%1 = Emission Type , %2 = Emission Unit of Measure Code';
        EnergyConsumptionUnitOfMeasureLbl: Label '%1 (%2)', Comment = '%1 = Emission Type , %2 = Energy Unit of Measure Code';
        PostedEnergyConsumptionUnitOfMeasureLbl: Label 'Posted %1 (%2)', Comment = '%1 = Emission Type , %2 = Energy Unit of Measure Code';
        PostedEnergyConsumptionLbl: Label 'Posted %1', Comment = '%1 = Emission Type';
        CO2eForCO2Txt: Label 'CO2e for CO2';
        CO2eForCH4Txt: Label 'CO2e for CH4';
        CO2eForN2OTxt: Label 'CO2e for N2O';
        CO2Txt: Label 'CO2';
        CH4Txt: Label 'CH4';
        N2OTxt: Label 'N2O';
        EnergyConsumptionTxt: Label 'Energy Consumption';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnResolveCaptionClass', '', true, true)]
    local procedure ResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        if CaptionArea = '102' then
            Caption := CurCaptionClassTranslate(CaptionExpr, Resolved);
    end;

    local procedure CurCaptionClassTranslate(CaptionExpr: Text; var Resolved: Boolean): Text
    var
        SustCaptionType: Text;
        SustCaptionRef: Text;
        UsageContext: Text;
        CommaPosition: Integer;
    begin
        // SustCaptionType
        // <DataType>   := [String]
        // <DataValue>  :=
        // '1' -> Net Change
        // '2' -> Balance at Date
        // '3' -> Balance
        // '4' -> %1
        // '5' -> Emission Factor
        // '6' -> Emission
        // '7' -> Baseline
        // '8' -> Current Value
        // '9' -> Target Value
        // '10' -> Default Emission
        // '11' -> Posted Emission
        // '12' -> Total Emission
        // '13' -> Energy Consumption
        // '14' -> Posted Energy Consumption

        // SustCaptionRef
        // <DataType>   := [SubString]
        // <DataValue>  := [String]
        // This string is the actual string making up the Caption.
        // It will contain a '%1', and the Emission Type will substitute for it.
        SustainabilitySetup.GetRecordOnce();

        CommaPosition := StrPos(CaptionExpr, ',');
        if CommaPosition > 0 then begin
            Resolved := true;
            SustCaptionType := CopyStr(CaptionExpr, 1, CommaPosition - 1);
            SustCaptionRef := CopyStr(CaptionExpr, CommaPosition + 1);

            case SustCaptionType of
                '1':
                    UsageContext := NetChangeLbl;
                '2':
                    UsageContext := BalanceAtDateLbl;
                '3':
                    UsageContext := BalanceLbl;
                '4':
                    UsageContext := '%1';
                '5':
                    UsageContext := EmissionFactorLbl;
                '6':
                    UsageContext := EmissionLbl;
                '7':
                    UsageContext := BaselineLbl;
                '8':
                    UsageContext := CurrentValueLbl;
                '9':
                    UsageContext := TargetValueLbl;
                '10':
                    UsageContext := DefaultEmissionLbl;
                '11':
                    UsageContext := PostedEmissionLbl;
                '12':
                    if SustainabilitySetup."Emission Unit of Measure Code" <> '' then
                        UsageContext := StrSubstNo(TotalEmissionUnitOfMeasureLbl, '%1', SustainabilitySetup."Emission Unit of Measure Code")
                    else
                        UsageContext := TotalEmissionLbl;
                '13':
                    if SustainabilitySetup."Energy Unit of Measure Code" <> '' then
                        UsageContext := StrSubstNo(EnergyConsumptionUnitOfMeasureLbl, '%1', SustainabilitySetup."Energy Unit of Measure Code")
                    else
                        UsageContext := '%1';
                '14':
                    if SustainabilitySetup."Energy Unit of Measure Code" <> '' then
                        UsageContext := StrSubstNo(PostedEnergyConsumptionUnitOfMeasureLbl, '%1', SustainabilitySetup."Energy Unit of Measure Code")
                    else
                        UsageContext := PostedEnergyConsumptionLbl;
            end;

            case SustCaptionRef of
                '1':
                    if SustainabilitySetup."Use All Gases As CO2e" then
                        exit(StrSubstNo(UsageContext, CO2eForCO2Txt))
                    else
                        exit(StrSubstNo(UsageContext, CO2Txt));
                '2':
                    if SustainabilitySetup."Use All Gases As CO2e" then
                        exit(StrSubstNo(UsageContext, CO2eForCH4Txt))
                    else
                        exit(StrSubstNo(UsageContext, CH4Txt));
                '3':
                    if SustainabilitySetup."Use All Gases As CO2e" then
                        exit(StrSubstNo(UsageContext, CO2eForN2OTxt))
                    else
                        exit(StrSubstNo(UsageContext, N2OTxt));
                '4':
                    exit(StrSubstNo(UsageContext, EnergyConsumptionTxt));
            end
        end;
        Resolved := false;
        exit('');
    end;
}