namespace Microsoft.Test.Sustainability;

using Microsoft.Sustainability.Setup;
using Microsoft.Foundation.UOM;

codeunit 148209 "Sust. Caption Class Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySustainability: Codeunit "Library - Sustainability";
        NetChangeLbl: Label 'Net Change (%1)', Comment = '%1 = Emission Type';
        BalanceAtDateLbl: Label 'Balance at Date (%1)', Comment = '%1 = Emission Type';
        BalanceLbl: Label 'Balance (%1)', Comment = '%1 = Emission Type';
        EmissionFactorLbl: Label 'Emission Factor %1', Comment = '%1 = Emission Type';
        EmissionLbl: Label 'Emission %1', Comment = '%1 = Emission Type';
        BaselineLbl: Label 'Baseline for %1', Comment = '%1 = Emission Type';
        CurrentValueLbl: Label 'Current Value for %1', Comment = '%1 = Emission Type';
        TargetValueLbl: Label 'Target Value for %1', Comment = '%1 = Emission Type';
        DefaultEmissionLbl: Label 'Default %1 Emission', Comment = '%1 = Emission Type';
        PostedEmissionLbl: Label 'Posted Emission %1', Comment = '%1 = Emission Type';
        TotalEmissionUnitOfMeasureLbl: Label 'Total Emission %1 (%2)', Comment = '%1 = Emission Type , %2 = Emission Unit of Measure Code';
        EnergyConsumptionUnitOfMeasureLbl: Label 'Energy Consumption (%1)', Comment = '%1 = Energy Unit of Measure Code';
        PostedEnergyConsumptionUnitOfMeasureLbl: Label 'Posted Energy Consumption (%1)', Comment = '%1 = Energy Unit of Measure Code';
        CaptionValueMustBeEqualErr: Label '%1 caption must be equal to %2 in the Page %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Page Caption';
        CO2eForCO2Txt: Label 'CO2e for CO2';
        CO2eForCH4Txt: Label 'CO2e for CH4';
        CO2eForN2OTxt: Label 'CO2e for N2O';

    [Test]
    procedure VerifyCaptionWhenUnitOfMeasureIsNotBlank()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        CaptionClassTestPage: TestPage "Sust. Caption Class Test Page";
    begin
        // [SCENARIO 554943] Verify caption When "Energy Unit of Measure" and "Emission Unit of Measure Code" is not blank in Sustainability Setup. 
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Energy Unit Of Measure", "Emission Unit of Measure Code" and "Use All Gases As CO2e" in Sustainability Setup.
        UpdateUnitOfMeasureAndUseAllGasesAsCO2eInSustainabilitySetup();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [WHEN] Get Caption Class Test Page.
        CaptionClassTestPage.OpenEdit();

        // [VERIFY] Verify caption When "Energy Unit of Measure" and "Emission Unit of Measure Code" is not blank in Sustainability Setup. 
        Assert.AreEqual(
            StrSubstNo(EnergyConsumptionUnitOfMeasureLbl, SustainabilitySetup."Energy Unit of Measure Code"),
            CaptionClassTestPage.EnergyConsumption.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.EnergyConsumption.Caption(), StrSubstNo(EnergyConsumptionUnitOfMeasureLbl, SustainabilitySetup."Energy Unit of Measure Code"), CaptionClassTestPage.Caption));

        Assert.AreEqual(
           StrSubstNo(PostedEnergyConsumptionUnitOfMeasureLbl, SustainabilitySetup."Energy Unit of Measure Code"),
           CaptionClassTestPage.PostedEnergyConsumption.Caption(),
           StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.PostedEnergyConsumption.Caption(), StrSubstNo(PostedEnergyConsumptionUnitOfMeasureLbl, SustainabilitySetup."Energy Unit of Measure Code"), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(NetChangeLbl, CO2eForCO2Txt),
            CaptionClassTestPage.NetChangeCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.NetChangeCO2.Caption(), StrSubstNo(NetChangeLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(NetChangeLbl, CO2eForCH4Txt),
            CaptionClassTestPage.NetChangeCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.NetChangeCH4.Caption(), StrSubstNo(NetChangeLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(NetChangeLbl, CO2eForN2OTxt),
            CaptionClassTestPage.NetChangeN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.NetChangeN2O.Caption(), StrSubstNo(NetChangeLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(BalanceAtDateLbl, CO2eForCO2Txt),
            CaptionClassTestPage.BalanceAtDateCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.BalanceAtDateCO2.Caption(), StrSubstNo(BalanceAtDateLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(BalanceAtDateLbl, CO2eForCH4Txt),
            CaptionClassTestPage.BalanceAtDateCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.BalanceAtDateCH4.Caption(), StrSubstNo(BalanceAtDateLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(BalanceAtDateLbl, CO2eForN2OTxt),
            CaptionClassTestPage.BalanceAtDateN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.BalanceAtDateN2O.Caption(), StrSubstNo(BalanceAtDateLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(BalanceLbl, CO2eForCO2Txt),
            CaptionClassTestPage.BalanceCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.BalanceCO2.Caption(), StrSubstNo(BalanceLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(BalanceLbl, CO2eForCH4Txt),
            CaptionClassTestPage.BalanceCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.BalanceCH4.Caption(), StrSubstNo(BalanceLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(BalanceLbl, CO2eForN2OTxt),
            CaptionClassTestPage.BalanceN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.BalanceN2O.Caption(), StrSubstNo(BalanceLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo('%1', CO2eForCO2Txt),
            CaptionClassTestPage.CO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.CO2.Caption(), StrSubstNo('%1', CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo('%1', CO2eForCH4Txt),
            CaptionClassTestPage.CH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.CH4.Caption(), StrSubstNo('%1', CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo('%1', CO2eForN2OTxt),
            CaptionClassTestPage.N2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.N2O.Caption(), StrSubstNo('%1', CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(EmissionFactorLbl, CO2eForCO2Txt),
            CaptionClassTestPage.EmissionFactorCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.EmissionFactorCO2.Caption(), StrSubstNo(EmissionFactorLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(EmissionFactorLbl, CO2eForCH4Txt),
            CaptionClassTestPage.EmissionFactorCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.EmissionFactorCH4.Caption(), StrSubstNo(EmissionFactorLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(EmissionFactorLbl, CO2eForN2OTxt),
            CaptionClassTestPage.EmissionFactorN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.EmissionFactorN2O.Caption(), StrSubstNo(EmissionFactorLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(EmissionLbl, CO2eForCO2Txt),
            CaptionClassTestPage.EmissionCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.EmissionCO2.Caption(), StrSubstNo(EmissionLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(EmissionLbl, CO2eForCH4Txt),
            CaptionClassTestPage.EmissionCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.EmissionCH4.Caption(), StrSubstNo(EmissionLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(EmissionLbl, CO2eForN2OTxt),
            CaptionClassTestPage.EmissionN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.EmissionN2O.Caption(), StrSubstNo(EmissionLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(BaselineLbl, CO2eForCO2Txt),
            CaptionClassTestPage.BaselineCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.BaselineCO2.Caption(), StrSubstNo(BaselineLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(BaselineLbl, CO2eForCH4Txt),
            CaptionClassTestPage.BaselineCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.BaselineCH4.Caption(), StrSubstNo(BaselineLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(BaselineLbl, CO2eForN2OTxt),
            CaptionClassTestPage.BaselineN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.BaselineN2O.Caption(), StrSubstNo(BaselineLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(CurrentValueLbl, CO2eForCO2Txt),
            CaptionClassTestPage.CurrentValueCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.CurrentValueCO2.Caption(), StrSubstNo(CurrentValueLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(CurrentValueLbl, CO2eForCH4Txt),
            CaptionClassTestPage.CurrentValueCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.CurrentValueCH4.Caption(), StrSubstNo(CurrentValueLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(CurrentValueLbl, CO2eForN2OTxt),
            CaptionClassTestPage.CurrentValueN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.CurrentValueN2O.Caption(), StrSubstNo(CurrentValueLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(TargetValueLbl, CO2eForCO2Txt),
            CaptionClassTestPage.TargetValueCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.TargetValueCO2.Caption(), StrSubstNo(TargetValueLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(TargetValueLbl, CO2eForCH4Txt),
            CaptionClassTestPage.TargetValueCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.TargetValueCH4.Caption(), StrSubstNo(TargetValueLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(TargetValueLbl, CO2eForN2OTxt),
            CaptionClassTestPage.TargetValueN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.TargetValueN2O.Caption(), StrSubstNo(TargetValueLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(DefaultEmissionLbl, CO2eForCO2Txt),
            CaptionClassTestPage.DefaultEmissionCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.DefaultEmissionCO2.Caption(), StrSubstNo(DefaultEmissionLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(DefaultEmissionLbl, CO2eForCH4Txt),
            CaptionClassTestPage.DefaultEmissionCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.DefaultEmissionCH4.Caption(), StrSubstNo(DefaultEmissionLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(DefaultEmissionLbl, CO2eForN2OTxt),
            CaptionClassTestPage.DefaultEmissionN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.DefaultEmissionN2O.Caption(), StrSubstNo(DefaultEmissionLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(PostedEmissionLbl, CO2eForCO2Txt),
            CaptionClassTestPage.PostedEmissionCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.PostedEmissionCO2.Caption(), StrSubstNo(PostedEmissionLbl, CO2eForCO2Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(PostedEmissionLbl, CO2eForCH4Txt),
            CaptionClassTestPage.PostedEmissionCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.PostedEmissionCH4.Caption(), StrSubstNo(PostedEmissionLbl, CO2eForCH4Txt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(PostedEmissionLbl, CO2eForN2OTxt),
            CaptionClassTestPage.PostedEmissionN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.PostedEmissionN2O.Caption(), StrSubstNo(PostedEmissionLbl, CO2eForN2OTxt), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(TotalEmissionUnitOfMeasureLbl, CO2eForCO2Txt, SustainabilitySetup."Emission Unit of Measure Code"),
            CaptionClassTestPage.TotalEmissionUnitOfMeasureCO2.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.TotalEmissionUnitOfMeasureCO2.Caption(), StrSubstNo(TotalEmissionUnitOfMeasureLbl, CO2eForCO2Txt, SustainabilitySetup."Emission Unit of Measure Code"), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(TotalEmissionUnitOfMeasureLbl, CO2eForCH4Txt, SustainabilitySetup."Emission Unit of Measure Code"),
            CaptionClassTestPage.TotalEmissionUnitOfMeasureCH4.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.TotalEmissionUnitOfMeasureCH4.Caption(), StrSubstNo(TotalEmissionUnitOfMeasureLbl, CO2eForCH4Txt, SustainabilitySetup."Emission Unit of Measure Code"), CaptionClassTestPage.Caption));

        Assert.AreEqual(
            StrSubstNo(TotalEmissionUnitOfMeasureLbl, CO2eForN2OTxt, SustainabilitySetup."Emission Unit of Measure Code"),
            CaptionClassTestPage.TotalEmissionUnitOfMeasureN2O.Caption(),
            StrSubstNo(CaptionValueMustBeEqualErr, CaptionClassTestPage.TotalEmissionUnitOfMeasureN2O.Caption(), StrSubstNo(TotalEmissionUnitOfMeasureLbl, CO2eForN2OTxt, SustainabilitySetup."Emission Unit of Measure Code"), CaptionClassTestPage.Caption));
    end;

    local procedure UpdateUnitOfMeasureAndUseAllGasesAsCO2eInSustainabilitySetup()
    var
        UnitOfMeasure: Record "Unit of Measure";
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        LibraryInventory.FindUnitOfMeasure(UnitOfMeasure);

        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("Energy Unit of Measure Code", UnitOfMeasure.Code);
        SustainabilitySetup.Validate("Emission Unit of Measure Code", UnitOfMeasure.Code);
        SustainabilitySetup.Validate("Use All Gases As CO2e", true);
        SustainabilitySetup.Modify();
    end;
}