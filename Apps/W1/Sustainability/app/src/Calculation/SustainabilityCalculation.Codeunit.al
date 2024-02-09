namespace Microsoft.Sustainability.Calculation;

using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Account;

codeunit 6215 "Sustainability Calculation"
{
    Access = Internal;

    internal procedure CalculateScope1Emissions(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainAccountCategory: Record "Sustain. Account Category"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        case SustainAccountCategory."Calculation Foundation" of
            Enum::"Calculation Foundation"::"Fuel/Electricity":
                CalculateFuelOrElectricityEmissions(SustainabilityJnlLine, SustainAccountSubcategory);
            Enum::"Calculation Foundation"::Distance:
                CalculateDistanceEmissions(SustainabilityJnlLine, SustainAccountSubcategory);
            Enum::"Calculation Foundation"::Installations:
                CalculateInstallationsEmissions(SustainabilityJnlLine, SustainAccountSubcategory)
            else
                Error(CalculationNotSupportedErr, SustainAccountCategory."Calculation Foundation", SustainAccountCategory."Emission Scope");
        end;
    end;

    internal procedure CalculateScope2Emissions(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainAccountCategory: Record "Sustain. Account Category"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        case SustainAccountCategory."Calculation Foundation" of
            Enum::"Calculation Foundation"::"Fuel/Electricity":
                CalculateFuelOrElectricityEmissions(SustainabilityJnlLine, SustainAccountSubcategory);
            Enum::"Calculation Foundation"::Custom:
                CalculateCustomEmissions(SustainabilityJnlLine, SustainAccountSubcategory);
            else
                Error(CalculationNotSupportedErr, SustainAccountCategory."Calculation Foundation", SustainAccountCategory."Emission Scope");
        end;
    end;

    internal procedure CalculateScope3Emissions(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainAccountCategory: Record "Sustain. Account Category"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        case SustainAccountCategory."Calculation Foundation" of
            Enum::"Calculation Foundation"::"Fuel/Electricity":
                CalculateFuelOrElectricityEmissions(SustainabilityJnlLine, SustainAccountSubcategory);
            Enum::"Calculation Foundation"::Distance:
                begin
                    SustainabilityJnlLine.Validate("Emission CO2", SustainabilityJnlLine.Distance * SustainAccountSubcategory."Emission Factor CO2" * SustainabilityJnlLine."Installation Multiplier");

                    SustainabilityJnlLine.Validate("Emission CH4", SustainabilityJnlLine.Distance * SustainAccountSubcategory."Emission Factor CH4" * SustainabilityJnlLine."Installation Multiplier");

                    SustainabilityJnlLine.Validate("Emission N2O", SustainabilityJnlLine.Distance * SustainAccountSubcategory."Emission Factor N2O" * SustainabilityJnlLine."Installation Multiplier");
                end;
            Enum::"Calculation Foundation"::Custom:
                CalculateCustomEmissions(SustainabilityJnlLine, SustainAccountSubcategory);
            else
                Error(CalculationNotSupportedErr, SustainAccountCategory."Calculation Foundation", SustainAccountCategory."Emission Scope");
        end;
    end;

    local procedure CalculateFuelOrElectricityEmissions(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        SustainabilityJnlLine.Validate("Emission CO2", SustainabilityJnlLine."Fuel/Electricity" * SustainAccountSubcategory."Emission Factor CO2");

        SustainabilityJnlLine.Validate("Emission CH4", SustainabilityJnlLine."Fuel/Electricity" * SustainAccountSubcategory."Emission Factor CH4");

        SustainabilityJnlLine.Validate("Emission N2O", SustainabilityJnlLine."Fuel/Electricity" * SustainAccountSubcategory."Emission Factor N2O");
    end;

    local procedure CalculateDistanceEmissions(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        SustainabilityJnlLine.Validate("Emission CO2", SustainabilityJnlLine.Distance * SustainAccountSubcategory."Emission Factor CO2");

        SustainabilityJnlLine.Validate("Emission CH4", SustainabilityJnlLine.Distance * SustainAccountSubcategory."Emission Factor CH4");

        SustainabilityJnlLine.Validate("Emission N2O", SustainabilityJnlLine.Distance * SustainAccountSubcategory."Emission Factor N2O");
    end;

    local procedure CalculateInstallationsEmissions(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        SustainabilityJnlLine.Validate("Emission CO2", CalculateInstallationEmission(SustainabilityJnlLine) * SustainAccountSubcategory."Emission Factor CO2");

        SustainabilityJnlLine.Validate("Emission CH4", CalculateInstallationEmission(SustainabilityJnlLine) * SustainAccountSubcategory."Emission Factor CH4");

        SustainabilityJnlLine.Validate("Emission N2O", CalculateInstallationEmission(SustainabilityJnlLine) * SustainAccountSubcategory."Emission Factor N2O");
    end;

    local procedure CalculateCustomEmissions(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        SustainabilityJnlLine.Validate("Emission CO2", SustainabilityJnlLine."Custom Amount" * SustainAccountSubcategory."Emission Factor CO2");

        SustainabilityJnlLine.Validate("Emission CH4", SustainabilityJnlLine."Custom Amount" * SustainAccountSubcategory."Emission Factor CH4");

        SustainabilityJnlLine.Validate("Emission N2O", SustainabilityJnlLine."Custom Amount" * SustainAccountSubcategory."Emission Factor N2O");
    end;

    local procedure CalculateInstallationEmission(SustainabilityJnlLine: Record "Sustainability Jnl. Line"): Decimal
    begin
        exit(SustainabilityJnlLine."Installation Multiplier" * SustainabilityJnlLine."Custom Amount" * SustainabilityJnlLine."Time Factor" / 100);
    end;

    var
        CalculationNotSupportedErr: Label 'Calculation Foundation %1 not supported for Scope %2', Comment = '%1 = Calculation Foundation; %2 = Emission Scope Type';
}