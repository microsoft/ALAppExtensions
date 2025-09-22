namespace Microsoft.Sustainability.Calculation;

using Microsoft.Purchases.Document;
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

    internal procedure CalculateWaterOrWaste(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainAccountCategory: Record "Sustain. Account Category"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        case SustainAccountCategory."Calculation Foundation" of
            Enum::"Calculation Foundation"::Custom:
                CalculateCustomEmissions(SustainabilityJnlLine, SustainAccountSubcategory);
            else
                Error(CalculationNotSupportedErr, SustainAccountCategory."Calculation Foundation", SustainAccountCategory."Emission Scope");
        end;
    end;

    internal procedure CalculateScope1Emissions(var PurchaseLine: Record "Purchase Line"; SustainabilityAccountCategory: Record "Sustain. Account Category"; SustainabilityAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        case SustainabilityAccountCategory."Calculation Foundation" of
            Enum::"Calculation Foundation"::"Fuel/Electricity":
                CalculateFuelOrElectricityEmissions(PurchaseLine, SustainabilityAccountSubcategory);
            Enum::"Calculation Foundation"::Distance:
                CalculateDistanceEmissions(PurchaseLine, SustainabilityAccountSubcategory);
            Enum::"Calculation Foundation"::Installations:
                CalculateInstallationsEmissions(PurchaseLine, SustainabilityAccountSubcategory)
            else
                Error(CalculationNotSupportedErr, SustainabilityAccountCategory."Calculation Foundation", SustainabilityAccountCategory."Emission Scope");
        end;
    end;

    internal procedure CalculateScope2Emissions(var PurchaseLine: Record "Purchase Line"; SustainabilityAccountCategory: Record "Sustain. Account Category"; SustainabilitySubCategory: Record "Sustain. Account Subcategory")
    begin
        case SustainabilityAccountCategory."Calculation Foundation" of
            Enum::"Calculation Foundation"::"Fuel/Electricity":
                CalculateFuelOrElectricityEmissions(PurchaseLine, SustainabilitySubCategory);
            Enum::"Calculation Foundation"::Custom:
                CalculateCustomEmissions(PurchaseLine, SustainabilitySubCategory);
            else
                Error(CalculationNotSupportedErr, SustainabilityAccountCategory."Calculation Foundation", SustainabilityAccountCategory."Emission Scope");
        end;
    end;

    internal procedure CalculateScope3Emissions(var PurchaseLine: Record "Purchase Line"; SustainabilityAccountCategory: Record "Sustain. Account Category"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        case SustainabilityAccountCategory."Calculation Foundation" of
            Enum::"Calculation Foundation"::"Fuel/Electricity":
                CalculateFuelOrElectricityEmissions(PurchaseLine, SustainAccountSubcategory);
            Enum::"Calculation Foundation"::Distance:
                begin
                    PurchaseLine.Validate("Emission CO2", PurchaseLine.Distance * SustainAccountSubcategory."Emission Factor CO2" * PurchaseLine."Installation Multiplier");

                    PurchaseLine.Validate("Emission CH4", PurchaseLine.Distance * SustainAccountSubcategory."Emission Factor CH4" * PurchaseLine."Installation Multiplier");

                    PurchaseLine.Validate("Emission N2O", PurchaseLine.Distance * SustainAccountSubcategory."Emission Factor N2O" * PurchaseLine."Installation Multiplier");
                end;
            Enum::"Calculation Foundation"::Custom:
                CalculateCustomEmissions(PurchaseLine, SustainAccountSubcategory);
            else
                Error(CalculationNotSupportedErr, SustainabilityAccountCategory."Calculation Foundation", SustainabilityAccountCategory."Emission Scope");
        end;
    end;

    internal procedure CalculateWaterOrWaste(var PurchaseLine: Record "Purchase Line"; SustainAccountCategory: Record "Sustain. Account Category"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        Error(CalculationNotSupportedErr, SustainAccountCategory."Calculation Foundation", SustainAccountCategory."Emission Scope");
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

        SustainabilityJnlLine.Validate("Water Intensity", SustainabilityJnlLine."Custom Amount" * SustainAccountSubcategory."Water Intensity Factor");

        SustainabilityJnlLine.Validate("Waste Intensity", SustainabilityJnlLine."Custom Amount" * SustainAccountSubcategory."Waste Intensity Factor");

        SustainabilityJnlLine.Validate("Discharged Into Water", SustainabilityJnlLine."Custom Amount" * SustainAccountSubcategory."Discharged Into Water Factor");
    end;

    local procedure CalculateInstallationEmission(SustainabilityJnlLine: Record "Sustainability Jnl. Line"): Decimal
    begin
        exit(SustainabilityJnlLine."Installation Multiplier" * SustainabilityJnlLine."Custom Amount" * SustainabilityJnlLine."Time Factor" / 100);
    end;

    local procedure CalculateFuelOrElectricityEmissions(var PurchaseLine: Record "Purchase Line"; SustainabilitySubcategory: Record "Sustain. Account Subcategory")
    begin
        PurchaseLine.Validate("Emission CO2", PurchaseLine."Fuel/Electricity" * SustainabilitySubcategory."Emission Factor CO2");

        PurchaseLine.Validate("Emission CH4", PurchaseLine."Fuel/Electricity" * SustainabilitySubcategory."Emission Factor CH4");

        PurchaseLine.Validate("Emission N2O", PurchaseLine."Fuel/Electricity" * SustainabilitySubcategory."Emission Factor N2O");
    end;

    local procedure CalculateDistanceEmissions(var PurchaseLine: Record "Purchase Line"; SustainabilitySubcategory: Record "Sustain. Account Subcategory")
    begin
        PurchaseLine.Validate("Emission CO2", PurchaseLine.Distance * SustainabilitySubcategory."Emission Factor CO2");

        PurchaseLine.Validate("Emission CH4", PurchaseLine.Distance * SustainabilitySubcategory."Emission Factor CH4");

        PurchaseLine.Validate("Emission N2O", PurchaseLine.Distance * SustainabilitySubcategory."Emission Factor N2O");
    end;

    local procedure CalculateInstallationsEmissions(var PurchaseLine: Record "Purchase Line"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        PurchaseLine.Validate("Emission CO2", CalculateInstallationEmission(PurchaseLine) * SustainAccountSubcategory."Emission Factor CO2");

        PurchaseLine.Validate("Emission CH4", CalculateInstallationEmission(PurchaseLine) * SustainAccountSubcategory."Emission Factor CH4");

        PurchaseLine.Validate("Emission N2O", CalculateInstallationEmission(PurchaseLine) * SustainAccountSubcategory."Emission Factor N2O");
    end;

    local procedure CalculateCustomEmissions(var PurchaseLine: Record "Purchase Line"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    begin
        PurchaseLine.Validate("Emission CO2", PurchaseLine."Custom Amount" * SustainAccountSubcategory."Emission Factor CO2");

        PurchaseLine.Validate("Emission CH4", PurchaseLine."Custom Amount" * SustainAccountSubcategory."Emission Factor CH4");

        PurchaseLine.Validate("Emission N2O", PurchaseLine."Custom Amount" * SustainAccountSubcategory."Emission Factor N2O");
    end;

    local procedure CalculateInstallationEmission(PurchaseLine: Record "Purchase Line"): Decimal
    begin
        exit(PurchaseLine."Installation Multiplier" * PurchaseLine."Custom Amount" * PurchaseLine."Time Factor" / 100);
    end;

    var
        CalculationNotSupportedErr: Label 'Calculation Foundation %1 not supported for Scope %2', Comment = '%1 = Calculation Foundation; %2 = Emission Scope Type';
}