codeunit 14099 "Create MX GL Accounts"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Common GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyCommonGLAccounts()
    var
        InventorySetup: Record "Inventory Setup";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        InventorySetup.Get();

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '6310');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '9410');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '1410');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '9610');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '9630');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '6120');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '6130');


        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '2110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '2110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '2410');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '2410');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '6130');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '2110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '2170');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '2170');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '6110');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '6111')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '1800');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '2500');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '2500');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '2410');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '2420');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '2421');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '2422');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '2423');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '2424');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '6120');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '6150');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '1220');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '1230');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '1240');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '8640');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '8820');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '8840');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '5850');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '10920');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '10950');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '40450');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '40250');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '50399');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '50300');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforMX()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomeStatementName(), '1000');
        ContosoGLAccount.AddAccountForLocalization(BankLcyPostingName(), '10100');
        ContosoGLAccount.AddAccountForLocalization(CashPostingName(), '10300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '6300');
        ContosoGLAccount.AddAccountForLocalization(InventoryPostingName(), '10700');
        ContosoGLAccount.AddAccountForLocalization(WipJobSalesPostingName(), '10910');
        ContosoGLAccount.AddAccountForLocalization(InvoicedJobSalesPostingName(), '10920');
        ContosoGLAccount.AddAccountForLocalization(AccruedJobCostsPostingName(), '10940');
        ContosoGLAccount.AddAccountForLocalization(WipJobCostsPostingName(), '10950');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '1100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfRetailName(), '1105');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '1110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEuName(), '1120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '1130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRetailName(), '1195');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfResourcesName(), '1405');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEuName(), '1420');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '1430');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfResourcesName(), '1495');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '1710');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesAndChargesRecDomName(), '1810');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '1910');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '1995');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayablePostingName(), '20100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '2100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailName(), '2105');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '2110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEuName(), '2120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '2130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '2140');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '2150');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '2170');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailSoldName(), '2190');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRetailName(), '2195');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '2995');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '3000');
        ContosoGLAccount.AddAccountForLocalization(CapitalStockPostingName(), '30100');
        ContosoGLAccount.AddAccountForLocalization(RetainedEarningsPostingName(), '30200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '3100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '3110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityAndHeatingName(), '3120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsAndMaintenanceName(), '3130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '3190');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '3200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '3210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneAndFaxName(), '3230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '3240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '3290');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '3300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '3310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '3320');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '3330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '3390');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '3400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '3410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentAndPrName(), '3420');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '3430');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '3450');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '3490');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '3500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineAndMotorOilName(), '3510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '3520');
        ContosoGLAccount.AddAccountForLocalization(RepairsAndMaintenancePostingName(), '3530');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '3590');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '3600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '3610');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '3620');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalAndAccountingServicesName(), '3630');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '3640');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), '3690');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), '3695');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '3700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '3710');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '3720');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '3730');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '3740');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '3750');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '3790');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationOfFixedAssetsName(), '3800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '3810');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '3820');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '3830');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsAndLossesName(), '3840');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '3890');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsOfOperationsName(), '3910');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '3995');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '40250');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '4100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnBankBalancesName(), '4110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesFromCustomersName(), '4120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '4130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscReceivedDecreasesName(), '4135');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '4140');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '4150');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '4160');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '4170');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), '4190');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '4200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnRevolvingCreditName(), '4210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnBankLoansName(), '4220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '4230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesToVendorsName(), '4240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '4250');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscGrantedDecreasesName(), '4255');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '4260');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '4270');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '4290');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxGainsName(), '4310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxLossesName(), '4320');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxGainsName(), '4330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxLossesName(), '4340');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NiBeforeExtrItemsTaxesName(), '4395');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '4410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '4420');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeBeforeTaxesName(), '4495');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '4510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeName(), '4999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalanceSheetName(), '5000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '5002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '5003');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '5005');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '50300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '5100');
        ContosoGLAccount.AddAccountForLocalization(LandAndBuildingsPostingName(), '5110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '5120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '5130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '5140');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandAndBuildingsTotalName(), '5190');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '5200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '5210');
        ContosoGLAccount.AddAccountForLocalization(IncreasesDuringTheYearPostingName(), '5220');
        ContosoGLAccount.AddAccountForLocalization(DecreasesDuringTheYearPostingName(), '5230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '5240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '5290');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '5300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '5310');
        ContosoGLAccount.AddAccountForLocalization(IncreasesDuringTheYearAssetsName(), '5320');
        ContosoGLAccount.AddAccountForLocalization(DecreasesDuringTheYearAssetsName(), '5330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '5340');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '5390');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '5395');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '5999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '6000');
        ContosoGLAccount.AddAccountForLocalization(SalariesPostingName(), '60700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '6100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '6110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '6111');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResaleSoldInterimName(), '6112');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '6120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '6121');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '6130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '6131');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMatSoldInterimName(), '6132');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '6180');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '6190');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipName(), '6200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesName(), '6210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobSalesName(), '6211');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '6212');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesTotalName(), '6220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsName(), '6230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobCostsName(), '6231');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '6232');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsTotalName(), '6240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipTotalName(), '6290');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '6310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '6320');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '6330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '6340');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '6390');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '6400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '6410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '6440');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '6800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '6810');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '6890');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '6900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '6910');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLcyName(), '6920');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '6930');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '6940');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '6990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '6995');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '6999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesAndEquityName(), '7000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '7100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '7110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '7120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeForTheYearName(), '7195');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '7199');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '8000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '8010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '8999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '9000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesName(), '9100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermBankLoansName(), '9110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '9120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesTotalName(), '9290');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesName(), '9300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '9310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '9350');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT0Name(), '9360');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '9390');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '9400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '9410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '9420');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '9490');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '9500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '9510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '9530');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), '9590');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatName(), '9600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '9710');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '9720');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '9730');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '9740');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Co2TaxName(), '9750');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '9760');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatPayableName(), '9780');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatTotalName(), '9790');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelRelatedItemsName(), '9800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '9810');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '9820');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '9830');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '9840');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '9850');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelRelatedItemsName(), '9890');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '9900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsForTheFiscalYearName(), '9910');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '9920');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '9990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesTotalName(), '9995');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '9997');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesAndEquityName(), '9999');
        ContosoGLAccount.AddAccountForLocalization(EquipmentName(), '10800');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationName(), '10900');
        ContosoGLAccount.AddAccountForLocalization(FeesAndChargesRecEuName(), '1820');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedName(), '40450');
        ContosoGLAccount.AddAccountForLocalization(JobCostsAppliedName(), '50399');
        ContosoGLAccount.AddAccountForLocalization(RentExpenseName(), '60100');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVat8PercName(), '6420');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVat16PercName(), '6430');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVat8PercName(), '9370');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVat16PercName(), '9380');
        ContosoGLAccount.AddAccountForLocalization(SalesVat16PercName(), '9610');
        ContosoGLAccount.AddAccountForLocalization(SalesVat8PercName(), '9611');
        ContosoGLAccount.AddAccountForLocalization(SalesVat16PercUnrealizedName(), '9615');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVat16PercEuName(), '9620');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVat8PercEuName(), '9621');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVat16PercEuUnrealName(), '9625');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVat16PercName(), '9630');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVat8PercName(), '9631');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVat16PercUnrealizedName(), '9635');
        ContosoGLAccount.AddAccountForLocalization(AccountsReceivablePostingName(), '10400');

        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat25EuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat10EuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesUsedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfResourcesName(), '');

        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        GLAccountCategory: Record "G/L Account Category";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreatePostingGroupsMX: Codeunit "Create Posting Groups MX";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateVATPostingGroupsMX: Codeunit "Create VAT Posting Groups MX";
        CreateGLAccount: Codeunit "Create G/L Account";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        SubCategory: Text[80];
    begin
        ContosoGLAccount.SetOverwriteData(true);
        ContosoGLAccount.InsertGLAccount(Equipment(), EquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciation(), AccumulatedDepreciationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetJobSalesContra(), 80);
        ContosoGLAccount.InsertGLAccount(JobSalesApplied(), JobSalesAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccount.InsertGLAccount(JobCostsApplied(), JobCostsAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategory."Account Category"::Assets);
        ContosoGLAccount.InsertGLAccount(RentExpense(), RentExpenseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalariesPosting(), SalariesPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetPrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVat8Perc(), VendorPrepaymentsVat8PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroupsMX.VAT8(), false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVat16Perc(), VendorPrepaymentsVat16PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroupsMX.VAT16(), false, false, false);
        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities);
        ContosoGLAccount.InsertGLAccount(SalesVat16PercUnrealized(), SalesVat16PercUnrealizedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetAR(), 80);
        ContosoGLAccount.InsertGLAccount(PurchaseVat16PercEu(), PurchaseVat16PercEuName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVat8PercEu(), PurchaseVat8PercEuName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVat16PercEuUnreal(), PurchaseVat16PercEuUnrealName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVat16Perc(), PurchaseVat16PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVat8Perc(), PurchaseVat8PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities);
        ContosoGLAccount.InsertGLAccount(PurchaseVat16PercUnrealized(), PurchaseVat16PercUnrealizedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankLcyPosting(), BankLcyPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetEquipment(), 80);
        ContosoGLAccount.InsertGLAccount(LandAndBuildingsPosting(), LandAndBuildingsPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CashPosting(), CashPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncreasesDuringTheYearPosting(), IncreasesDuringTheYearPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), true, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesDuringTheYearPosting(), DecreasesDuringTheYearPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), false, false, false);
        ContosoGLAccount.InsertGLAccount(IncreasesDuringTheYearAssets(), IncreasesDuringTheYearAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), true, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesDuringTheYearAssets(), DecreasesDuringTheYearAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsReceivablePosting(), AccountsReceivablePostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryPosting(), InventoryPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategory."Account Category"::Expense);
        ContosoGLAccount.InsertGLAccount(RetainedEarningsPosting(), RetainedEarningsPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapitalStockPosting(), CapitalStockPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetRepairsExpense(), 80);
        ContosoGLAccount.InsertGLAccount(RepairsAndMaintenancePosting(), RepairsAndMaintenancePostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayablePosting(), AccountsPayablePostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategory."Account Category"::Income);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncomeStatement(), CreateGLAccount.IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategory."Account Category"::Assets);
        ContosoGLAccount.InsertGLAccount(WIPJobSalesPosting(), WIPJobSalesPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvoicedJobSalesPosting(), InvoicedJobSalesPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedJobCostsPosting(), AccruedJobCostsPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WipJobCostsPosting(), WipJobCostsPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetIncomeProdSales(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailDom(), CreateGLAccount.SalesRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailEU(), CreateGLAccount.SalesRetailEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT16(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailExport(), CreateGLAccount.SalesRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroupsMX.VAT16(), false, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetIncomeService(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesDom(), CreateGLAccount.SalesResourcesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT8(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesEU(), CreateGLAccount.SalesResourcesEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT8(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesExport(), CreateGLAccount.SalesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroupsMX.VAT8(), false, false, false);
        ContosoGLAccount.InsertGLAccount(FeesAndChargesRecEu(), FeesAndChargesRecEuName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.FreightPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT16(), true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetIncomeService(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultingFeesDom(), CreateGLAccount.ConsultingFeesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT8(), true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetUtilitiesExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroupsMX.NOVAT(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.NOVAT(), true, false, false);
        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Travel(), CreateGLAccount.TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroupsMX.NOVAT(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.NOVAT(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RegistrationFees(), CreateGLAccount.RegistrationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroupsMX.NOVAT(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.NOVAT(), true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetOperatingIncome(), CreateGLAccount.NetOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetOperatingIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeJobs(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSales(), CreateGLAccount.JobSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroupsMX.NOVAT(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.NOVAT(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroupsMX.NOVAT(), 0, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.NOVAT(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NIBEFOREEXTRITEMSTAXES(), CreateGLAccount.NIBEFOREEXTRITEMSTAXESName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NIBEFOREEXTRITEMSTAXES(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncomeBeforeTaxes(), CreateGLAccount.NetIncomeBeforeTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetIncomeBeforeTaxes(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncome(), CreateGLAccount.NetIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BalanceSheet(), CreateGLAccount.BalanceSheetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetJobsCost(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorPrepaymentsVAT(), CreateGLAccount.VendorPrepaymentsVATName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroupsMX.NOVAT(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroupsMX.NOVAT(), false, false, false);
        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LiabilitiesAndEquity(), CreateGLAccount.LiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CorporateTaxesPayable(), CreateGLAccount.CorporateTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetCurrentLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomerPrepaymentsVAT0(), CreateGLAccount.CustomerPrepaymentsVAT0Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroupsMX.NOVAT(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroupsMX.NOVAT(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVat8Perc(), CustomerPrepaymentsVat8PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroupsMX.VAT8(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVat16Perc(), CustomerPrepaymentsVat16PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroupsMX.VAT16(), false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVat16Perc(), SalesVat16PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVat8Perc(), SalesVat8PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilitiesTotal(), CreateGLAccount.OtherLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OtherLiabilities() + '..' + CreateGLAccount.OtherLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ShorttermLiabilitiesTotal(), CreateGLAccount.ShorttermLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.ShorttermLiabilities() + '..' + CreateGLAccount.ShorttermLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategory."Account Category"::Equity, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilitiesAndEquity(), CreateGLAccount.TotalLiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, CreateGLAccount.LiabilitiesAndEquity() + '..' + CreateGLAccount.TotalLiabilitiesAndEquity() + '|' + CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, true);
        ContosoGLAccount.SetOverwriteData(false);
    end;

    procedure AddCategoriesToGLAccounts()
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        if GLAccountCategory.IsEmpty() then
            exit;

        GLAccountCategory.SetRange("Parent Entry No.", 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignCategoryToChartOfAccounts(GLAccountCategory);
            until GLAccountCategory.Next() = 0;
    end;

    procedure AssignCategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                UpdateGLAccounts(GLAccountCategory, BankLcyPosting(), AccumulatedDepreciation());
            GLAccountCategory."Account Category"::Liabilities:
                begin
                    UpdateGLAccounts(GLAccountCategory, AccountsPayablePosting(), AccountsPayablePosting());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CorporateTaxesPayable(), CreateGLAccount.CorporateTaxesPayable());
                end;
        end;
    end;

    procedure UpdateVATProdPostingGroupOnGL()
    var
        GLAccount: Record "G/L Account";
        CreateVATPostingGroupsMX: Codeunit "Create VAT Posting Groups MX";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        GLAccount.SetFilter("VAT Prod. Posting Group", '<>%1', '');
        if GLAccount.FindSet() then
            repeat
                if GLAccount."VAT Prod. Posting Group" = CreateVATPostingGroups.Reduced() then
                    GLAccount.Validate("VAT Prod. Posting Group", CreateVATPostingGroupsMX.VAT8());
                if GLAccount."VAT Prod. Posting Group" = CreateVATPostingGroups.Standard() then
                    GLAccount.Validate("VAT Prod. Posting Group", CreateVATPostingGroupsMX.VAT16());
                if GLAccount."VAT Prod. Posting Group" = CreateVATPostingGroups.Zero() then
                    GLAccount.Validate("VAT Prod. Posting Group", CreateVATPostingGroupsMX.NOVAT());
                GLAccount.Modify(true);
            until GLAccount.Next() = 0;
    end;

    local procedure UpdateGLAccounts(GLAccountCategory: Record "G/L Account Category"; FromGLAccountNo: Code[20]; ToGLAccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("No.", FromGLAccountNo, ToGLAccountNo);
        if GLAccount.FindSet() then begin
            GLAccount.ModifyAll("Account Category", GLAccountCategory."Account Category", false);
            GLAccount.ModifyAll("Account Subcategory Entry No.", GLAccountCategory."Entry No.", false);
        end;
    end;

    procedure UpdateDebitCreditOnGL()
    var
        GLAccount: Record "G/L Account";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        UpdateDebitCreditOnGLAccount(WipJobSalesPosting(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(InvoicedJobSalesPosting(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(AccruedJobCostsPosting(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(WipJobCostsPosting(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(JobSalesApplied(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(CreateGLAccount.JobCosts(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(CreateGLAccount.JobSales(), GLAccount."Debit/Credit"::Credit);
        UpdateDebitCreditOnGLAccount(JobCostsApplied(), GLAccount."Debit/Credit"::Credit);
    end;

    local procedure UpdateDebitCreditOnGLAccount(GLAccountNo: Code[20]; DebitCredit: Option)
    var
        GLAccount: Record "G/L Account";
    begin
        GlAccount.Get(GLAccountNo);

        GLAccount.Validate("Debit/Credit", DebitCredit);
        GLAccount.Modify(true);
    end;

    procedure Equipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquipmentName()));
    end;

    procedure EquipmentName(): Text[100]
    begin
        exit(EquipmentTok)
    end;

    procedure AccumulatedDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationName()));
    end;

    procedure AccumulatedDepreciationName(): Text[100]
    begin
        exit(AccumulatedDepreciationTok)
    end;

    procedure FeesAndChargesRecEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FeesAndChargesRecEuName()));
    end;

    procedure FeesAndChargesRecEuName(): Text[100]
    begin
        exit(FeesAndChargesRecEuTok)
    end;

    procedure JobSalesApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedName()));
    end;

    procedure JobSalesAppliedName(): Text[100]
    begin
        exit(JobSalesAppliedTok)
    end;

    procedure JobCostsApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostsAppliedName()));
    end;

    procedure JobCostsAppliedName(): Text[100]
    begin
        exit(JobCostsAppliedTok)
    end;

    procedure RentExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentExpenseName()));
    end;

    procedure RentExpenseName(): Text[100]
    begin
        exit(RentExpenseTok)
    end;

    procedure VendorPrepaymentsVat8Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVat8PercName()));
    end;

    procedure VendorPrepaymentsVat8PercName(): Text[100]
    begin
        exit(VendorPrepaymentsVat8PercTok)
    end;

    procedure VendorPrepaymentsVat16Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVat16PercName()));
    end;

    procedure VendorPrepaymentsVat16PercName(): Text[100]
    begin
        exit(VendorPrepaymentsVat16PercTok)
    end;

    procedure CustomerPrepaymentsVat8Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVat8PercName()));
    end;

    procedure CustomerPrepaymentsVat8PercName(): Text[100]
    begin
        exit(CustomerPrepaymentsVat8PercTok)
    end;

    procedure CustomerPrepaymentsVat16Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVat16PercName()));
    end;

    procedure CustomerPrepaymentsVat16PercName(): Text[100]
    begin
        exit(CustomerPrepaymentsVat16PercTok)
    end;

    procedure SalesVat16Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVat16PercName()));
    end;

    procedure SalesVat16PercName(): Text[100]
    begin
        exit(SalesVat16PercTok)
    end;

    procedure SalesVat8Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVat8PercName()));
    end;

    procedure SalesVat8PercName(): Text[100]
    begin
        exit(SalesVat8PercTok)
    end;

    procedure SalesVat16PercUnrealized(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVat16PercUnrealizedName()));
    end;

    procedure SalesVat16PercUnrealizedName(): Text[100]
    begin
        exit(SalesVat16PercUnrealizedTok)
    end;

    procedure PurchaseVat16PercEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVat16PercEuName()));
    end;

    procedure PurchaseVat16PercEuName(): Text[100]
    begin
        exit(PurchaseVat16PercEuTok)
    end;

    procedure PurchaseVat8PercEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVat8PercEuName()));
    end;

    procedure PurchaseVat8PercEuName(): Text[100]
    begin
        exit(PurchaseVat8PercEuTok)
    end;

    procedure PurchaseVat16PercEuUnreal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVat16PercEuUnrealName()));
    end;

    procedure PurchaseVat16PercEuUnrealName(): Text[100]
    begin
        exit(PurchaseVat16PercEuUnrealTok)
    end;

    procedure PurchaseVat16Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVat16PercName()));
    end;

    procedure PurchaseVat16PercName(): Text[100]
    begin
        exit(PurchaseVat16PercTok)
    end;

    procedure PurchaseVat8Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVat8PercName()));
    end;

    procedure PurchaseVat8PercName(): Text[100]
    begin
        exit(PurchaseVat8PercTok)
    end;

    procedure PurchaseVat16PercUnrealized(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVat16PercUnrealizedName()));
    end;

    procedure PurchaseVat16PercUnrealizedName(): Text[100]
    begin
        exit(PurchaseVat16PercUnrealizedTok)
    end;

    procedure LandAndBuildingsPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandAndBuildingsPostingName()));
    end;

    procedure LandAndBuildingsPostingName(): Text[100]
    begin
        exit(LandAndBuildingsPostingTok)
    end;

    procedure IncreasesDuringTheYearPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncreasesDuringTheYearPostingName()));
    end;

    procedure IncreasesDuringTheYearPostingName(): Text[100]
    begin
        exit(IncreasesDuringTheYearPostingTok)
    end;

    procedure DecreasesDuringTheYearPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesDuringTheYearPostingName()));
    end;

    procedure DecreasesDuringTheYearPostingName(): Text[100]
    begin
        exit(DecreasesDuringTheYearPostingTok)
    end;

    procedure IncreasesDuringTheYearAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncreasesDuringTheYearAssetsName()));
    end;

    procedure IncreasesDuringTheYearAssetsName(): Text[100]
    begin
        exit(IncreasesDuringTheYearAssetsTok)
    end;

    procedure DecreasesDuringTheYearAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesDuringTheYearAssetsName()));
    end;

    procedure DecreasesDuringTheYearAssetsName(): Text[100]
    begin
        exit(DecreasesDuringTheYearAssetsTok)
    end;

    procedure AccountsReceivablePosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsReceivablePostingName()));
    end;

    procedure AccountsReceivablePostingName(): Text[100]
    begin
        exit(AccountsReceivablePostingTok);
    end;

    procedure BankLcyPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankLcyPostingName()));
    end;

    procedure BankLcyPostingName(): Text[100]
    begin
        exit(BankLcyPostingTok);
    end;

    procedure CashPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashPostingName()));
    end;

    procedure CashPostingName(): Text[100]
    begin
        exit(CashPostingTok);
    end;

    procedure InventoryPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryPostingName()));
    end;

    procedure InventoryPostingName(): Text[100]
    begin
        exit(InventoryPostingTok);
    end;

    procedure AccruedJobCostsPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedJobCostsPostingName()));
    end;

    procedure AccruedJobCostsPostingName(): Text[100]
    begin
        exit(AccruedJobCostsPostingTok);
    end;

    procedure WipJobCostsPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WipJobCostsPostingName()));
    end;

    procedure WipJobCostsPostingName(): Text[100]
    begin
        exit(WipJobCostsPostingTok);
    end;

    procedure CapitalStockPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapitalStockPostingName()));
    end;

    procedure CapitalStockPostingName(): Text[100]
    begin
        exit(CapitalStockPostingTok);
    end;

    procedure RepairsAndMaintenancePosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsAndMaintenancePostingName()));
    end;

    procedure RepairsAndMaintenancePostingName(): Text[100]
    begin
        exit(RepairsAndMaintenancePostingTok);
    end;

    procedure SalariesPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalariesPostingName()));
    end;

    procedure SalariesPostingName(): Text[100]
    begin
        exit(SalariesPostingTok);
    end;

    procedure RetainedEarningsPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RetainedEarningsPostingName()));
    end;

    procedure RetainedEarningsPostingName(): Text[100]
    begin
        exit(RetainedEarningsPostingTok);
    end;

    procedure AccountsPayablePosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayablePostingName()));
    end;

    procedure AccountsPayablePostingName(): Text[100]
    begin
        exit(AccountsPayablePostingTok);
    end;

    procedure WIPJobSalesPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPJobSalesPostingName()));
    end;

    procedure WIPJobSalesPostingName(): Text[100]
    begin
        exit(WIPJobSalesPostingTok);
    end;

    procedure InvoicedJobSalesPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvoicedJobSalesPostingName()));
    end;

    procedure InvoicedJobSalesPostingName(): Text[100]
    begin
        exit(InvoicedJobSalesPostingTok);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        EquipmentTok: Label 'Equipment', MaxLength = 100;
        AccumulatedDepreciationTok: Label 'Accumulated Depreciation', MaxLength = 100;
        FeesAndChargesRecEuTok: Label 'Fees and Charges Rec. - EU', MaxLength = 100;
        JobSalesAppliedTok: Label 'Job Sales Applied', MaxLength = 100;
        JobCostsAppliedTok: Label 'Job Costs Applied', MaxLength = 100;
        RentExpenseTok: Label 'Rent Expense', MaxLength = 100;
        VendorPrepaymentsVat8PercTok: Label 'Vendor Prepayments VAT 8 %', MaxLength = 100;
        VendorPrepaymentsVat16PercTok: Label 'Vendor Prepayments VAT 16 %', MaxLength = 100;
        CustomerPrepaymentsVat8PercTok: Label 'Customer Prepayments VAT 8 %', MaxLength = 100;
        CustomerPrepaymentsVat16PercTok: Label 'Customer Prepayments VAT 16 %', MaxLength = 100;
        SalesVat16PercTok: Label 'Sales VAT 16 %', MaxLength = 100;
        SalesVat8PercTok: Label 'Sales VAT 8 %', MaxLength = 100;
        SalesVat16PercUnrealizedTok: Label 'Sales VAT 16 % Unrealized', MaxLength = 100;
        PurchaseVat16PercEuTok: Label 'Purchase VAT 16 % EU', MaxLength = 100;
        PurchaseVat8PercEuTok: Label 'Purchase VAT 8 % EU', MaxLength = 100;
        PurchaseVat16PercEuUnrealTok: Label 'Purchase VAT 16 % EU Unreal.', MaxLength = 100;
        PurchaseVat16PercTok: Label 'Purchase VAT 16 %', MaxLength = 100;
        PurchaseVat8PercTok: Label 'Purchase VAT 8 %', MaxLength = 100;
        PurchaseVat16PercUnrealizedTok: Label 'Purchase VAT 16 % Unrealized', MaxLength = 100;
        IncreasesduringtheYearPostingTok: Label 'Increases during the Year, Posting', MaxLength = 100;
        LandAndBuildingsPostingTok: Label 'Land and Buildings, Posting', MaxLength = 100;
        DecreasesDuringTheYearPostingTok: Label 'Decreases during the Year, Posting', MaxLength = 100;
        DecreasesDuringTheYearAssetsTok: Label 'Decreases during the Year, Assets', MaxLength = 100;
        IncreasesduringtheYearAssetsTok: Label 'Increases during the Year, Assets', MaxLength = 100;
        AccountsReceivablePostingTok: Label 'Accounts Receivable, Posting', MaxLength = 100;
        BankLcyPostingTok: Label 'Bank Lcy, Posting', MaxLength = 100;
        CashPostingTok: Label 'Cash, Posting', MaxLength = 100;
        InventoryPostingTok: Label 'Inventory, Posting', MaxLength = 100;
        AccruedJobCostsPostingTok: Label 'Accrued Job Costs, Posting', MaxLength = 100;
        WipJobCostsPostingTok: Label 'WIP Job Costs, Posting', MaxLength = 100;
        CapitalStockPostingTok: Label 'Capital Stock, Posting', MaxLength = 100;
        RepairsAndMaintenancePostingTok: Label 'Repairs And Maintenance, Posting', MaxLength = 100;
        SalariesPostingTok: Label 'Salaries, Posting', MaxLength = 100;
        RetainedEarningsPostingTok: Label 'Retained Earnings, Posting', MaxLength = 100;
        AccountsPayablePostingTok: Label 'Accounts Payable, Posting', MaxLength = 100;
        WIPJobSalesPostingTok: Label 'WIP Job Sales, Posting', MaxLength = 100;
        InvoicedJobSalesPostingTok: Label 'Invoiced Job Sales, Posting', MaxLength = 100;
}