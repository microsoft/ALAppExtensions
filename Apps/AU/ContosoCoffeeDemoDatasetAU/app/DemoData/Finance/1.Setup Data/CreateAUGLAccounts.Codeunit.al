codeunit 17107 "Create AU GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '1210');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '2245');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '4110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '5101');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '2305');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '2310');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '5319');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '5109');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '5380');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '5110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '5111');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '5385');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '1330');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '5315');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '5340');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '5105');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '1310');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '1311')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '4730');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '5471');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '5472');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '5479');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '5695');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '5700');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '5710');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '5720');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '5730');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '1320');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '1340');
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
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '1411');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '1431');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '4150');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '4500');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '5106');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '5459');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccount()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '1001');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '1002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '1003');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '1005');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLcyName(), '1010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '1015');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '1200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '1210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '1220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '1230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '1240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '1300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '1310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '1311');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResaleSoldInterimName(), '1312');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '1320');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '1321');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '1330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '1331');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMatSoldInterimName(), '1332');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '1380');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipName(), '1400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobSalesName(), '1411');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '1412');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsName(), '1430');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobCostsName(), '1431');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '1432');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '1511');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '1515');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '1520');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandAndBuildingsName(), '1521');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '1530');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '1543');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '1550');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '1551');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '1554');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesAndEquityName(), '2000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '2010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesName(), '2020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermBankLoansName(), '2030');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '2040');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesName(), '2101');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '2102');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '2103');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '2106');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '2242');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '2245');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '2250');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '2275');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '2279');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '2280');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelRelatedItemsName(), '2360');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '2370');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '2375');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '2376');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '2377');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '2378');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '2500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsForTheFiscalYearName(), '2510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '2520');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '3000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '3010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '3020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '3040');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomeStatementName(), '4000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '4010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfRetailName(), '4100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '4110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '4145');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '4150');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '4200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfRawMaterialsName(), '4230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '4240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '4250');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '4300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '4310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfResourcesName(), '4340');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '4350');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '4400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '4410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '4430');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfJobsName(), '4440');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '4450');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '4500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '4751');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnBankBalancesName(), '4752');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesFromCustomersName(), '4753');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '4754');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscReceivedDecreasesName(), '4755');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '4756');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '4757');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '4758');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '4759');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '4780');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesAndChargesRecDomName(), '4790');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '4795');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '5000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailName(), '5100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '5101');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '5102');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '5103');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '5105');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '5106');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '5107');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailSoldName(), '5108');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsName(), '5300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '5315');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '5320');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '5330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '5340');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '5345');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '5349');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsSoldName(), '5360');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesName(), '5400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesUsedName(), '5410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '5420');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '5430');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '5459');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '6000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '6005');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '6010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityAndHeatingName(), '6015');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsAndMaintenanceName(), '6020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '6035');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '6040');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneAndFaxName(), '6045');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '6050');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '6065');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '6070');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '6080');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '6190');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '6200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '6225');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentAndPrName(), '6235');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '6245');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '6300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineAndMotorOilName(), '6325');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '6330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsAndMaintenanceExpenseName(), '6398');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '6400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '6411');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '6412');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalAndAccountingServicesName(), '6413');
        ContosoGLAccount.AddAccountForLocalization(MiscellaneousExpenseName(), '6414');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '6500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '6520');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '6530');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '6540');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '6570');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationOfFixedAssetsName(), '7100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '7110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '7120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '7130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsOfOperationsName(), '7150');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '7200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnRevolvingCreditName(), '7210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnBankLoansName(), '7220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '7230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesToVendorsName(), '7240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscGrantedDecreasesName(), '7250');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '7260');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '7270');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '7280');
        ContosoGLAccount.AddAccountForLocalization(GainsAndLossesBeginTotalName(), '7300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxGainsName(), '7400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxLossesName(), '7500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxGainsName(), '7600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxLossesName(), '7610');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsAndLossesName(), '7620');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '8020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '8030');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '1099');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '1290');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '1399');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesTotalName(), '1420');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsTotalName(), '1433');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipTotalName(), '1440');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandAndBuildingsTotalName(), '1531');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '1555');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '1599');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '1699');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesTotalName(), '2100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), '2281');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelRelatedItemsName(), '2379');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesTotalName(), '2399');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '2530');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '2999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeForTheYearName(), '3045');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '3050');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesAndEquityName(), '3999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRetailName(), '4210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRawMaterialsName(), '4330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfResourcesName(), '4439');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfJobsName(), '4510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), '4899');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '4900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRetailName(), '5299');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRawMaterialsName(), '5390');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfResourcesName(), '5450');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '5799');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '6025');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '6055');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '6199');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '6299');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '6399');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), '6430');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), '6499');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '6599');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '7140');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '7290');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Miscellaneous(), '8640');
        ContosoGLAccount.AddAccountForLocalization(StmtOfFinancialPositionName(), '1000');
        ContosoGLAccount.AddAccountForLocalization(BankOtherName(), '1020');
        ContosoGLAccount.AddAccountForLocalization(CustomersIntercompanyName(), '1225');
        ContosoGLAccount.AddAccountForLocalization(WipAccountFinishedGoodsName(), '1340');
        ContosoGLAccount.AddAccountForLocalization(TotalCurrentAssetsName(), '1499');
        ContosoGLAccount.AddAccountForLocalization(NonCurrentAssetsName(), '1500');
        ContosoGLAccount.AddAccountForLocalization(FinancialAssetsName(), '1504');
        ContosoGLAccount.AddAccountForLocalization(InvestmentsName(), '1505');
        ContosoGLAccount.AddAccountForLocalization(OtherFinancialAssetsName(), '1510');
        ContosoGLAccount.AddAccountForLocalization(TotalFinancialAssetsName(), '1514');
        ContosoGLAccount.AddAccountForLocalization(OfficeEquipmentBeginTotalName(), '1541');
        ContosoGLAccount.AddAccountForLocalization(OfficeEquipmentName(), '1542');
        ContosoGLAccount.AddAccountForLocalization(OfficeEquipmentTotalName(), '1549');
        ContosoGLAccount.AddAccountForLocalization(IntangibleAssetsBeginTotalName(), '1600');
        ContosoGLAccount.AddAccountForLocalization(IntangibleAssetsName(), '1605');
        ContosoGLAccount.AddAccountForLocalization(AccAmortnOnIntangiblesName(), '1610');
        ContosoGLAccount.AddAccountForLocalization(IntangibleAssetsTotalName(), '1650');
        ContosoGLAccount.AddAccountForLocalization(RightToUseAssetsName(), '1670');
        ContosoGLAccount.AddAccountForLocalization(RightToUseLeasesName(), '1671');
        ContosoGLAccount.AddAccountForLocalization(AccAmortnOnRightOfUseLeasesName(), '1672');
        ContosoGLAccount.AddAccountForLocalization(RightToUseAssetsTotalName(), '1673');
        ContosoGLAccount.AddAccountForLocalization(TotalNonCurrentAssetsName(), '1698');
        ContosoGLAccount.AddAccountForLocalization(PrepaidServiceContractsName(), '2104');
        ContosoGLAccount.AddAccountForLocalization(DeferredRevenueName(), '2105');
        ContosoGLAccount.AddAccountForLocalization(TradeAndOtherPayablesBeginTotalName(), '2240');
        ContosoGLAccount.AddAccountForLocalization(VendorsIntercompanyName(), '2251');
        ContosoGLAccount.AddAccountForLocalization(AccruedExpensesName(), '2253');
        ContosoGLAccount.AddAccountForLocalization(ProvisionForIncomeTaxName(), '2255');
        ContosoGLAccount.AddAccountForLocalization(ProvisionForAnnualLeaveName(), '2259');
        ContosoGLAccount.AddAccountForLocalization(SuperannuationClearingName(), '2260');
        ContosoGLAccount.AddAccountForLocalization(PayrollClearingName(), '2261');
        ContosoGLAccount.AddAccountForLocalization(PayrollDeductionsName(), '2270');
        ContosoGLAccount.AddAccountForLocalization(TradeAndOtherPayablesName(), '2274');
        ContosoGLAccount.AddAccountForLocalization(TaxesPayablesName(), '2300');
        ContosoGLAccount.AddAccountForLocalization(GstPayableName(), '2305');
        ContosoGLAccount.AddAccountForLocalization(GstReceivableName(), '2310');
        ContosoGLAccount.AddAccountForLocalization(GstClearingName(), '2320');
        ContosoGLAccount.AddAccountForLocalization(GstReconName(), '2330');
        ContosoGLAccount.AddAccountForLocalization(WhtTaxPayableName(), '2340');
        ContosoGLAccount.AddAccountForLocalization(WhtPrepaidName(), '2341');
        ContosoGLAccount.AddAccountForLocalization(TaxesPayablesTotalName(), '2350');
        ContosoGLAccount.AddAccountForLocalization(UnearnedRevenueOtherName(), '2380');
        ContosoGLAccount.AddAccountForLocalization(FundsReceivedInAdvanceName(), '2381');
        ContosoGLAccount.AddAccountForLocalization(OtherCurrentLiabilitiesName(), '2382');
        ContosoGLAccount.AddAccountForLocalization(TotalUnearnedRevenueOtherName(), '2390');
        ContosoGLAccount.AddAccountForLocalization(NonCurrentLiabilitiesName(), '2400');
        ContosoGLAccount.AddAccountForLocalization(EmployeeProvisionsName(), '2410');
        ContosoGLAccount.AddAccountForLocalization(LongServiceLeaveName(), '2420');
        ContosoGLAccount.AddAccountForLocalization(TotalEmployeeProvisionsName(), '2450');
        ContosoGLAccount.AddAccountForLocalization(TotalNonCurrentLiabilitiesName(), '2540');
        ContosoGLAccount.AddAccountForLocalization(StockSalesName(), '4120');
        ContosoGLAccount.AddAccountForLocalization(HireIncomeName(), '4130');
        ContosoGLAccount.AddAccountForLocalization(RentalIncomeName(), '4140');
        ContosoGLAccount.AddAccountForLocalization(SalesOfServiceContractsName(), '4726');
        ContosoGLAccount.AddAccountForLocalization(ServiceContractSaleName(), '4730');
        ContosoGLAccount.AddAccountForLocalization(TotalSaleOfServContractsName(), '4740');
        ContosoGLAccount.AddAccountForLocalization(FreightExpensesRetailName(), '5104');
        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedRetailName(), '5109');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedRetailName(), '5110');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceRetailName(), '5111');
        ContosoGLAccount.AddAccountForLocalization(FreightExpensesRawMatCOGSName(), '5335');
        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedRawmatName(), '5370');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedRawmatName(), '5380');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceRawmatName(), '5385');
        ContosoGLAccount.AddAccountForLocalization(CostOfCapacitiesBeginTotalName(), '5460');
        ContosoGLAccount.AddAccountForLocalization(CostOfCapacitiesName(), '5470');
        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedCapName(), '5471');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedCapName(), '5472');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceCapName(), '5479');
        ContosoGLAccount.AddAccountForLocalization(TotalCostOfCapacitiesName(), '5480');
        ContosoGLAccount.AddAccountForLocalization(VarianceName(), '5490');
        ContosoGLAccount.AddAccountForLocalization(MaterialVarianceName(), '5695');
        ContosoGLAccount.AddAccountForLocalization(CapacityVarianceName(), '5700');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedVarianceName(), '5710');
        ContosoGLAccount.AddAccountForLocalization(CapOverheadVarianceName(), '5720');
        ContosoGLAccount.AddAccountForLocalization(MfgOverheadVarianceName(), '5730');
        ContosoGLAccount.AddAccountForLocalization(TotalVarianceName(), '5731');
        ContosoGLAccount.AddAccountForLocalization(FreightExpensesRawMatName(), '6255');
        ContosoGLAccount.AddAccountForLocalization(AnnualLeaveExpensesName(), '6560');
        ContosoGLAccount.AddAccountForLocalization(EbitdaName(), '7000');
        ContosoGLAccount.AddAccountForLocalization(PurchaseWhtAdjustmentsName(), '7160');
        ContosoGLAccount.AddAccountForLocalization(SalesWhtAdjustmentsName(), '7170');
        ContosoGLAccount.AddAccountForLocalization(TotalGainsAndLossesName(), '7999');
        ContosoGLAccount.AddAccountForLocalization(NiBefExtrItemsTaxesName(), '8005');
        ContosoGLAccount.AddAccountForLocalization(IncomeTaxesName(), '8010');
        ContosoGLAccount.AddAccountForLocalization(TotalIncomeTaxesName(), '8049');
        ContosoGLAccount.AddAccountForLocalization(OtherComprehensiveNetIncomeTaxForThePeriodBeginTotalName(), '8060');
        ContosoGLAccount.AddAccountForLocalization(OtherComprehensiveNetIncomeTaxForThePeriodName(), '8070');
        ContosoGLAccount.AddAccountForLocalization(NetIncomeBeforeExtrItemsName(), '8099');
        ContosoGLAccount.AddAccountForLocalization(TotalComprehensiveIncomeForThePeriodName(), '8199');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CO2TaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NIBEFOREEXTRITEMSTAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeBeforeTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeName(), '');
        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.SetOverwriteData(true);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LiquidAssets(), CreateGLAccount.LiquidAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPSales(), CreateGLAccount.WIPSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultingFeesDom(), CreateGLAccount.ConsultingFeesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FeesandChargesRecDom(), CreateGLAccount.FeesandChargesRecDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cleaning(), CreateGLAccount.CleaningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ElectricityandHeating(), CreateGLAccount.ElectricityandHeatingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RepairsandMaintenance(), CreateGLAccount.RepairsandMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PhoneandFax(), CreateGLAccount.PhoneandFaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Software(), CreateGLAccount.SoftwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultantServices(), CreateGLAccount.ConsultantServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherComputerExpenses(), CreateGLAccount.OtherComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Advertising(), CreateGLAccount.AdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.EntertainmentandPR(), CreateGLAccount.EntertainmentandPRName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Travel(), CreateGLAccount.TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GasolineandMotorOil(), CreateGLAccount.GasolineandMotorOilName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RegistrationFees(), CreateGLAccount.RegistrationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RepairsandMaintenanceExpense(), CreateGLAccount.RepairsandMaintenanceExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LegalandAccountingServices(), CreateGLAccount.LegalandAccountingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscellaneousExpense(), MiscellaneousExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CorporateTax(), CreateGLAccount.CorporateTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(StmtOfFinancialPosition(), StmtOfFinancialPositionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankOther(), BankOtherName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CustomersIntercompany(), CustomersIntercompanyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WipAccountFinishedGoods(), WipAccountFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCurrentAssets(), TotalCurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CurrentAssets() + '..' + TotalCurrentAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NonCurrentAssets(), NonCurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialAssets(), FinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Investments(), InvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherFinancialAssets(), OtherFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFinancialAssets(), TotalFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, FinancialAssets() + '..' + TotalFinancialAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeEquipmentBeginTotal(), OfficeEquipmentBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeEquipment(), OfficeEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeEquipmentTotal(), OfficeEquipmentTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, OfficeEquipmentBeginTotal() + '..' + OfficeEquipmentTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleAssetsBeginTotal(), IntangibleAssetsBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleAssets(), IntangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccAmortnOnIntangibles(), AccAmortnOnIntangiblesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleAssetsTotal(), IntangibleAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, IntangibleAssetsBeginTotal() + '..' + IntangibleAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RightToUseAssets(), RightToUseAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RightToUseLeases(), RightToUseLeasesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccAmortnOnRightOfUseLeases(), AccAmortnOnRightOfUseLeasesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RightToUseAssetsTotal(), RightToUseAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, RightToUseAssets() + '..' + RightToUseAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalNonCurrentAssets(), TotalNonCurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, NonCurrentAssets() + '..' + TotalNonCurrentAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidServiceContracts(), PrepaidServiceContractsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredRevenue(), DeferredRevenueName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeAndOtherPayablesBeginTotal(), TradeAndOtherPayablesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorsIntercompany(), VendorsIntercompanyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedExpenses(), AccruedExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionForIncomeTax(), ProvisionForIncomeTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionForAnnualLeave(), ProvisionForAnnualLeaveName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SuperannuationClearing(), SuperannuationClearingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayrollClearing(), PayrollClearingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayrollDeductions(), PayrollDeductionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeAndOtherPayables(), TradeAndOtherPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, TradeAndOtherPayables() + '..' + TradeAndOtherPayables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesPayables(), TaxesPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GstPayable(), GstPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GstReceivable(), GstReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GstClearing(), GstClearingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GstRecon(), GstReconName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WhtTaxPayable(), WhtTaxPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WhtPrepaid(), WhtPrepaidName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesPayablesTotal(), TaxesPayablesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, TaxesPayables() + '..' + TaxesPayablesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(UnearnedRevenueOther(), UnearnedRevenueOtherName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FundsReceivedInAdvance(), FundsReceivedInAdvanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCurrentLiabilities(), OtherCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalUnearnedRevenueOther(), TotalUnearnedRevenueOtherName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, UnearnedRevenueOther() + '..' + TotalUnearnedRevenueOther(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NonCurrentLiabilities(), NonCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EmployeeProvisions(), EmployeeProvisionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LongServiceLeave(), LongServiceLeaveName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalEmployeeProvisions(), TotalEmployeeProvisionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, EmployeeProvisions() + '..' + TotalEmployeeProvisions(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalNonCurrentLiabilities(), TotalNonCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, NonCurrentLiabilities() + '..' + TotalNonCurrentLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StockSales(), StockSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HireIncome(), HireIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RentalIncome(), RentalIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesOfServiceContracts(), SalesOfServiceContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceContractSale(), ServiceContractSaleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSaleOfServContracts(), TotalSaleOfServContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesOfServiceContracts() + '..' + TotalSaleOfServContracts(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FreightExpensesRetail(), FreightExpensesRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DirectCostAppliedRetail(), DirectCostAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedRetail(), OverheadAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceRetail(), PurchaseVarianceRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FreightExpensesRawMatCOGS(), FreightExpensesRawMatCOGSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DirectCostAppliedRawmat(), DirectCostAppliedRawmatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedRawmat(), OverheadAppliedRawmatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceRawmat(), PurchaseVarianceRawmatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfCapacitiesBeginTotal(), CostOfCapacitiesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfCapacities(), CostOfCapacitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DirectCostAppliedCap(), DirectCostAppliedCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedCap(), OverheadAppliedCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceCap(), PurchaseVarianceCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostOfCapacities(), TotalCostOfCapacitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostOfCapacitiesBeginTotal() + '..' + TotalCostOfCapacities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variance(), VarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MaterialVariance(), MaterialVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapacityVariance(), CapacityVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SubcontractedVariance(), SubcontractedVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapOverheadVariance(), CapOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MfgOverheadVariance(), MfgOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalVariance(), TotalVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, Variance() + '..' + TotalVariance(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FreightExpensesRawMat(), FreightExpensesRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnnualLeaveExpenses(), AnnualLeaveExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Ebitda(), EbitdaName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseWhtAdjustments(), PurchaseWhtAdjustmentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesWhtAdjustments(), SalesWhtAdjustmentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalGainsAndLosses(), TotalGainsAndLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, GainsAndLossesBeginTotal() + '..' + TotalGainsAndLosses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NiBefExtrItemsTaxes(), NiBefExtrItemsTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Total, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeTaxes(), IncomeTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalIncomeTaxes(), TotalIncomeTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, IncomeTaxes() + '..' + TotalIncomeTaxes(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherComprehensiveNetIncomeTaxForThePeriodBeginTotal(), OtherComprehensiveNetIncomeTaxForThePeriodBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherComprehensiveNetIncomeTaxForThePeriod(), OtherComprehensiveNetIncomeTaxForThePeriodName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NetIncomeBeforeExtrItems(), NetIncomeBeforeExtrItemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Total, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalComprehensiveIncomeForThePeriod(), TotalComprehensiveIncomeForThePeriodName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherComprehensiveNetIncomeTaxForThePeriodBeginTotal() + '..' + TotalComprehensiveIncomeForThePeriod(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LiquidAssetsTotal(), CreateGLAccount.LiquidAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LiquidAssets() + '..' + CreateGLAccount.LiquidAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsReceivableTotal(), CreateGLAccount.AccountsReceivableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.AccountsReceivable() + '..' + CreateGLAccount.AccountsReceivableTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryTotal(), CreateGLAccount.InventoryTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Inventory() + '..' + CreateGLAccount.InventoryTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WipSalesTotal(), CreateGLAccount.WipSalesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.WipSales() + '..' + CreateGLAccount.WipSalesTotal(), Enum::"General Posting Type"::Sale, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WipCostsTotal(), CreateGLAccount.WipCostsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.WipCosts() + '..' + CreateGLAccount.WipCostsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobWipTotal(), CreateGLAccount.JobWipTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.JobWip() + '..' + CreateGLAccount.JobWipTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LandAndBuildingsTotal(), CreateGLAccount.LandAndBuildingsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LandandBuildingsBeginTotal() + '..' + CreateGLAccount.LandAndBuildingsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VehiclesTotal(), CreateGLAccount.VehiclesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.VehiclesBeginTotal() + '..' + CreateGLAccount.VehiclesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TangibleFixedAssetsTotal(), CreateGLAccount.TangibleFixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.TangibleFixedAssets() + '..' + CreateGLAccount.TangibleFixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalAssets(), CreateGLAccount.TotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 1, CreateGLAccount.Assets() + '..' + CreateGLAccount.TotalAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LongTermLiabilitiesTotal(), CreateGLAccount.LongTermLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LongTermLiabilities() + '..' + CreateGLAccount.LongTermLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimTotal(), CreateGLAccount.InvAdjmtInterimTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.InvAdjmtInterim() + '..' + CreateGLAccount.InvAdjmtInterimTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalPersonnelRelatedItems(), CreateGLAccount.TotalPersonnelRelatedItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PersonnelRelatedItems() + '..' + CreateGLAccount.TotalPersonnelRelatedItems(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ShortTermLiabilitiesTotal(), CreateGLAccount.ShortTermLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.ShortTermLiabilities() + '..' + CreateGLAccount.ShortTermLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilitiesTotal(), CreateGLAccount.OtherLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OtherLiabilities() + '..' + CreateGLAccount.OtherLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilities(), CreateGLAccount.TotalLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Liabilities() + '..' + CreateGLAccount.TotalLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncomeForTheYear(), CreateGLAccount.NetIncomeForTheYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalStockholder(), CreateGLAccount.TotalStockholderName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilitiesAndEquity(), CreateGLAccount.TotalLiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Total, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSalesOfRetail(), CreateGLAccount.TotalSalesOfRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesOfRetail() + '..' + CreateGLAccount.TotalSalesOfRetail(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSalesOfRawMaterials(), CreateGLAccount.TotalSalesOfRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesOfRawMaterials() + '..' + CreateGLAccount.TotalSalesOfRawMaterials(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSalesOfResources(), CreateGLAccount.TotalSalesOfResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesOfResources() + '..' + CreateGLAccount.TotalSalesOfResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSalesOfJobs(), CreateGLAccount.TotalSalesOfJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesOfJobs() + '..' + CreateGLAccount.TotalSalesOfJobs(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalInterestIncome(), CreateGLAccount.TotalInterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.InterestIncome() + '..' + CreateGLAccount.TotalInterestIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalRevenue(), CreateGLAccount.TotalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Revenue() + '..' + CreateGLAccount.TotalRevenue(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalCostOfRetail(), CreateGLAccount.TotalCostOfRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CostOfRetail() + '..' + CreateGLAccount.TotalCostOfRetail(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalCostOfRawMaterials(), CreateGLAccount.TotalCostOfRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CostOfRawMaterials() + '..' + CreateGLAccount.TotalCostOfRawMaterials(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalCostOfResources(), CreateGLAccount.TotalCostOfResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CostOfResources() + '..' + CreateGLAccount.TotalCostOfResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalCost(), CreateGLAccount.TotalCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Cost() + '..' + CreateGLAccount.TotalCost(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalBldgMaintExpenses(), CreateGLAccount.TotalBldgMaintExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.BuildingMaintenanceExpenses() + '..' + CreateGLAccount.TotalBldgMaintExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalAdministrativeExpenses(), CreateGLAccount.TotalAdministrativeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.AdministrativeExpenses() + '..' + CreateGLAccount.TotalAdministrativeExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalComputerExpenses(), CreateGLAccount.TotalComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.ComputerExpenses() + '..' + CreateGLAccount.TotalComputerExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSellingExpenses(), CreateGLAccount.TotalSellingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SellingExpenses() + '..' + CreateGLAccount.TotalSellingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalVehicleExpenses(), CreateGLAccount.TotalVehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.VehicleExpenses() + '..' + CreateGLAccount.TotalVehicleExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherOperatingExpTotal(), CreateGLAccount.OtherOperatingExpTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OtherOperatingExpenses() + '..' + CreateGLAccount.OtherOperatingExpTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalOperatingExpenses(), CreateGLAccount.TotalOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OperatingExpenses() + '..' + CreateGLAccount.TotalOperatingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalPersonnelExpenses(), CreateGLAccount.TotalPersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PersonnelExpenses() + '..' + CreateGLAccount.TotalPersonnelExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalFixedAssetDepreciation(), CreateGLAccount.TotalFixedAssetDepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.DepreciationOfFixedAssets() + '..' + CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalInterestExpenses(), CreateGLAccount.TotalInterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.InterestExpenses() + '..' + CreateGLAccount.TotalInterestExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchasePrepayments(), CreateGLAccount.PurchasePrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesPrepayments(), CreateGLAccount.SalesPrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsPayable(), CreateGLAccount.AccountsPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Allowances(), CreateGLAccount.AllowancesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GainsAndLossesBeginTotal(), GainsAndLossesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersForeign(), CreateGLAccount.CustomersForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Vehicles(), CreateGLAccount.VehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LandandBuildings(), CreateGLAccount.LandandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDeprOperEquip(), CreateGLAccount.AccumDeprOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GainsandLosses(), CreateGLAccount.GainsandLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDepreciationVehicles(), CreateGLAccount.AccumDepreciationVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BankLCY(), CreateGLAccount.BankLCYName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BankCurrencies(), CreateGLAccount.BankCurrenciesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersDomestic(), CreateGLAccount.CustomersDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItemsInterim(), CreateGLAccount.ResaleItemsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.CostofResaleSoldInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoodsInterim(), CreateGLAccount.FinishedGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterialsInterim(), CreateGLAccount.RawMaterialsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRawMatSoldInterim(), CreateGLAccount.CostofRawMatSoldInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PrimoInventory(), CreateGLAccount.PrimoInventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobSales(), CreateGLAccount.WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoicedJobSales(), CreateGLAccount.InvoicedJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobCosts(), CreateGLAccount.WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccruedJobCosts(), CreateGLAccount.AccruedJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDepreciationBuildings(), CreateGLAccount.AccumDepreciationBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RevolvingCredit(), CreateGLAccount.RevolvingCreditName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeferredTaxes(), CreateGLAccount.DeferredTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsDomestic(), CreateGLAccount.VendorsDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsForeign(), CreateGLAccount.VendorsForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimRetail(), CreateGLAccount.InvAdjmtInterimRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimRawMat(), CreateGLAccount.InvAdjmtInterimRawMatName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncomeStatement(), CreateGLAccount.IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CapitalStock(), CreateGLAccount.CapitalStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RetainedEarnings(), CreateGLAccount.RetainedEarningsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailDom(), CreateGLAccount.SalesRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailExport(), CreateGLAccount.SalesRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedRetail(), CreateGLAccount.JobSalesAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAdjmtRetail(), CreateGLAccount.JobSalesAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsDom(), CreateGLAccount.SalesRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsExport(), CreateGLAccount.SalesRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedRawMat(), CreateGLAccount.JobSalesAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAdjmtRawMat(), CreateGLAccount.JobSalesAdjmtRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesDom(), CreateGLAccount.SalesResourcesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesExport(), CreateGLAccount.SalesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedResources(), CreateGLAccount.JobSalesAppliedResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAdjmtResources(), CreateGLAccount.JobSalesAdjmtResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesOtherJobExpenses(), CreateGLAccount.SalesOtherJobExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PaymentDiscountsReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtDiscReceivedDecreases(), CreateGLAccount.PmtDiscReceivedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentToleranceReceived(), CreateGLAccount.PaymentToleranceReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PmtTolReceivedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailDom(), CreateGLAccount.PurchRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailExport(), CreateGLAccount.PurchRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedRetail(), CreateGLAccount.JobCostAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAdjmtRetail(), CreateGLAccount.JobCostAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofRetailSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsDom(), CreateGLAccount.PurchRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsExport(), CreateGLAccount.PurchRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryAdjmtRawMat(), CreateGLAccount.InventoryAdjmtRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedRawMat(), CreateGLAccount.JobCostAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAdjmtRawMaterials(), CreateGLAccount.JobCostAdjmtRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRawMaterialsSold(), CreateGLAccount.CostofRawMaterialsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedResources(), CreateGLAccount.JobCostAppliedResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAdjmtResources(), CreateGLAccount.JobCostAdjmtResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtDiscGrantedDecreases(), CreateGLAccount.PmtDiscGrantedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PaymentToleranceGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtTolGrantedDecreases(), CreateGLAccount.PmtTolGrantedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.UnrealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.UnrealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RealizedFXGains(), CreateGLAccount.RealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RealizedFXLosses(), CreateGLAccount.RealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.SetOverwriteData(false);
    end;

    procedure AddCategoriesToMiniGLAccounts()
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        if GLAccountCategory.IsEmpty() then
            exit;

        GLAccountCategory.SetRange("Parent Entry No.", 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignCategoryToMiniChartOfAccounts(GLAccountCategory);
            until GLAccountCategory.Next() = 0;

        GLAccountCategory.SetFilter("Parent Entry No.", '<>%1', 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignSubcategoryToMiniChartOfAccounts(GLAccountCategory);
            until GLAccountCategory.Next() = 0;
    end;

    local procedure AssignCategoryToMiniChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Assets(), CreateGLAccount.TotalAssets());
            GLAccountCategory."Account Category"::Liabilities:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LiabilitiesAndEquity(), CreateGLAccount.TotalLiabilities());
            GLAccountCategory."Account Category"::Equity:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Stockholder(), CreateGLAccount.TotalLiabilitiesAndEquity());
            GLAccountCategory."Account Category"::Income:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.IncomeStatement(), CreateGLAccount.TotalRevenue());
                    UpdateGLAccounts(GLAccountCategory, GainsandLossesBeginTotal(), TotalGainsAndLosses());
                end;
            GLAccountCategory."Account Category"::"Cost of Goods Sold":
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Cost(), CreateGLAccount.TotalCost());
            GLAccountCategory."Account Category"::Expense:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.OperatingExpenses(), CreateGLAccount.TotalInterestExpenses());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.UnrealizedFXLosses());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RealizedFXLosses(), CreateGLAccount.RealizedFXLosses());
                    UpdateGLAccounts(GLAccountCategory, NiBefExtrItemsTaxes(), TotalComprehensiveIncomeForThePeriod());
                end;
        end;
    end;

    local procedure AssignSubcategoryToMiniChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory.Description of
            GLAccountCategoryMgt.GetCash():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LiquidAssets(), CreateGLAccount.LiquidAssetsTotal());
            GLAccountCategoryMgt.GetAR():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.AccountsReceivable(), CreateGLAccount.AccountsReceivableTotal());
            GLAccountCategoryMgt.GetPrepaidExpenses():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.JobWIP(), CreateGLAccount.JobWIP());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PurchasePrepayments(), CreateGLAccount.PurchasePrepayments());
                end;
            GLAccountCategoryMgt.GetInventory():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Inventory(), CreateGLAccount.InventoryTotal());
            GLAccountCategoryMgt.GetEquipment():
                UpdateGLAccounts(GLAccountCategory, OfficeEquipmentBeginTotal(), CreateGLAccount.VehiclesTotal());
            GLAccountCategoryMgt.GetAccumDeprec():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.AccumDepreciationBuildings(), CreateGLAccount.AccumDepreciationBuildings());
            GLAccountCategoryMgt.GetCurrentLiabilities():
                begin
                    UpdateGLAccounts(GLAccountCategory, TradeAndOtherPayablesBeginTotal(), TaxesPayablesTotal());
                    UpdateGLAccounts(GLAccountCategory, NonCurrentLiabilities(), NonCurrentLiabilities());
                end;
            GLAccountCategoryMgt.GetPayrollLiabilities():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PersonnelExpenses(), CreateGLAccount.TotalPersonnelExpenses());
            GLAccountCategoryMgt.GetLongTermLiabilities():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LongtermLiabilities(), CreateGLAccount.LongtermLiabilitiesTotal());
                    UpdateGLAccounts(GLAccountCategory, DeferredRevenue(), CreateGLAccount.DeferredTaxes());
                end;
            GLAccountCategoryMgt.GetCommonStock():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CapitalStock(), CreateGLAccount.CapitalStock());
            GLAccountCategoryMgt.GetRetEarnings():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RetainedEarnings(), CreateGLAccount.RetainedEarnings());
            GLAccountCategoryMgt.GetDistrToShareholders():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.TotalStockholder(), CreateGLAccount.TotalStockholder());
            GLAccountCategoryMgt.GetIncomeService():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.SalesResourcesDom(), TotalSaleOfServContracts());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.ConsultingFeesDom(), CreateGLAccount.FeesandChargesRecDom());
                end;
            GLAccountCategoryMgt.GetIncomeProdSales():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.SalesofRetail(), CreateGLAccount.SalesRetailDom());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.SalesRetailExport(), CreateGLAccount.SalesRetailExport());
                end;
            GLAccountCategoryMgt.GetIncomeSalesDiscounts():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted());
            GLAccountCategoryMgt.GetCOGSLabor():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CostofResources(), PurchaseVarianceCap());
            GLAccountCategoryMgt.GetCOGSMaterials():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CostofRetail(), CreateGLAccount.TotalCostofRawMaterials());
            GLAccountCategoryMgt.GetAdvertisingExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Advertising(), CreateGLAccount.EntertainmentandPR());
            GLAccountCategoryMgt.GetInterestExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.InterestExpenses(), CreateGLAccount.TotalInterestExpenses());
            GLAccountCategoryMgt.GetPayrollExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PersonnelExpenses(), CreateGLAccount.TotalPersonnelExpenses());
            GLAccountCategoryMgt.GetRepairsExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RepairsandMaintenanceExpense(), CreateGLAccount.RepairsandMaintenanceExpense());
            GLAccountCategoryMgt.GetUtilitiesExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.BuildingMaintenanceExpenses(), CreateGLAccount.TotalAdministrativeExpenses());
            GLAccountCategoryMgt.GetOtherIncomeExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.OtherOperatingExpenses(), CreateGLAccount.TotalOperatingExpenses());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.OtherCostsofOperations(), CreateGLAccount.OtherCostsofOperations());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.ExtraordinaryExpenses(), CreateGLAccount.ExtraordinaryExpenses());
                end;
            GLAccountCategoryMgt.GetTaxExpense():
                UpdateGLAccounts(GLAccountCategory, IncomeTaxes(), TotalComprehensiveIncomeForThePeriod());
        end;
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

    procedure StmtOfFinancialPosition(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StmtOfFinancialPositionName()));
    end;

    procedure StmtOfFinancialPositionName(): Text[100]
    begin
        exit(StmtOfFinancialPositionTok);
    end;

    procedure BankOther(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankOtherName()));
    end;

    procedure BankOtherName(): Text[100]
    begin
        exit(BankOtherTok);
    end;

    procedure CustomersIntercompany(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomersIntercompanyName()));
    end;

    procedure CustomersIntercompanyName(): Text[100]
    begin
        exit(CustomersIntercompanyTok);
    end;

    procedure WipAccountFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WipAccountFinishedGoodsName()));
    end;

    procedure WipAccountFinishedGoodsName(): Text[100]
    begin
        exit(WipAccountFinishedGoodsTok);
    end;

    procedure TotalCurrentAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCurrentAssetsName()));
    end;

    procedure TotalCurrentAssetsName(): Text[100]
    begin
        exit(TotalCurrentAssetsTok);
    end;

    procedure NonCurrentAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonCurrentAssetsName()));
    end;

    procedure NonCurrentAssetsName(): Text[100]
    begin
        exit(NonCurrentAssetsTok);
    end;

    procedure FinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialAssetsName()));
    end;

    procedure FinancialAssetsName(): Text[100]
    begin
        exit(FinancialAssetsTok);
    end;

    procedure Investments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvestmentsName()));
    end;

    procedure InvestmentsName(): Text[100]
    begin
        exit(InvestmentsTok);
    end;

    procedure OtherFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherFinancialAssetsName()));
    end;

    procedure OtherFinancialAssetsName(): Text[100]
    begin
        exit(OtherFinancialAssetsTok);
    end;

    procedure TotalFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFinancialAssetsName()));
    end;

    procedure TotalFinancialAssetsName(): Text[100]
    begin
        exit(TotalFinancialAssetsTok);
    end;

    procedure OfficeEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeEquipmentName()));
    end;

    procedure OfficeEquipmentName(): Text[100]
    begin
        exit(OfficeEquipmentTok);
    end;

    procedure OfficeEquipmentBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeEquipmentBegintotalName()));
    end;

    procedure OfficeEquipmentBeginTotalName(): Text[100]
    begin
        exit(OfficeEquipmentBeginTotalTok);
    end;

    procedure OfficeEquipmentTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeEquipmentTotalName()));
    end;

    procedure OfficeEquipmentTotalName(): Text[100]
    begin
        exit(OfficeEquipmentTotalTok);
    end;

    procedure IntangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleAssetsName()));
    end;

    procedure IntangibleAssetsName(): Text[100]
    begin
        exit(IntangibleAssetsTok);
    end;

    procedure IntangibleAssetsBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleAssetsBeginTotalName()));
    end;

    procedure IntangibleAssetsBeginTotalName(): Text[100]
    begin
        exit(IntangibleAssetsBeginTotalTok);
    end;

    procedure AccAmortnOnIntangibles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccAmortnOnIntangiblesName()));
    end;

    procedure AccAmortnOnIntangiblesName(): Text[100]
    begin
        exit(AccAmortnOnIntangiblesTok);
    end;

    procedure IntangibleAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleAssetsTotalName()));
    end;

    procedure IntangibleAssetsTotalName(): Text[100]
    begin
        exit(IntangibleAssetsTotalTok);
    end;

    procedure RightToUseAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RightToUseAssetsName()));
    end;

    procedure RightToUseAssetsName(): Text[100]
    begin
        exit(RightToUseAssetsTok);
    end;

    procedure RightToUseLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RightToUseLeasesName()));
    end;

    procedure RightToUseLeasesName(): Text[100]
    begin
        exit(RightToUseLeasesTok);
    end;

    procedure AccAmortnOnRightOfUseLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccAmortnOnRightOfUseLeasesName()));
    end;

    procedure AccAmortnOnRightOfUseLeasesName(): Text[100]
    begin
        exit(AccAmortnOnRightOfUseLeasesTok);
    end;

    procedure RightToUseAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RightToUseAssetsTotalName()));
    end;

    procedure RightToUseAssetsTotalName(): Text[100]
    begin
        exit(RightToUseAssetsTotalTok);
    end;

    procedure TotalNonCurrentAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalNonCurrentAssetsName()));
    end;

    procedure TotalNonCurrentAssetsName(): Text[100]
    begin
        exit(TotalNonCurrentAssetsTok);
    end;

    procedure PrepaidServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidServiceContractsName()));
    end;

    procedure PrepaidServiceContractsName(): Text[100]
    begin
        exit(PrepaidServiceContractsTok);
    end;

    procedure DeferredRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredRevenueName()));
    end;

    procedure DeferredRevenueName(): Text[100]
    begin
        exit(DeferredRevenueTok);
    end;

    procedure TradeAndOtherPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeAndOtherPayablesName()));
    end;

    procedure TradeAndOtherPayablesName(): Text[100]
    begin
        exit(TradeAndOtherPayablesTok);
    end;

    procedure TradeAndOtherPayablesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeAndOtherPayablesBeginTotalName()));
    end;

    procedure TradeAndOtherPayablesBeginTotalName(): Text[100]
    begin
        exit(TradeAndOtherPayablesBeginTotalTok);
    end;

    procedure VendorsIntercompany(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsIntercompanyName()));
    end;

    procedure VendorsIntercompanyName(): Text[100]
    begin
        exit(VendorsIntercompanyTok);
    end;

    procedure AccruedExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedExpensesName()));
    end;

    procedure AccruedExpensesName(): Text[100]
    begin
        exit(AccruedExpensesTok);
    end;

    procedure ProvisionForIncomeTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionForIncomeTaxName()));
    end;

    procedure ProvisionForIncomeTaxName(): Text[100]
    begin
        exit(ProvisionForIncomeTaxTok);
    end;

    procedure ProvisionForAnnualLeave(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionForAnnualLeaveName()));
    end;

    procedure ProvisionForAnnualLeaveName(): Text[100]
    begin
        exit(ProvisionForAnnualLeaveTok);
    end;

    procedure SuperannuationClearing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SuperannuationClearingName()));
    end;

    procedure SuperannuationClearingName(): Text[100]
    begin
        exit(SuperannuationClearingTok);
    end;

    procedure PayrollClearing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollClearingName()));
    end;

    procedure PayrollClearingName(): Text[100]
    begin
        exit(PayrollClearingTok);
    end;

    procedure PayrollDeductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollDeductionsName()));
    end;

    procedure PayrollDeductionsName(): Text[100]
    begin
        exit(PayrollDeductionsTok);
    end;

    procedure TaxesPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesPayablesName()));
    end;

    procedure TaxesPayablesName(): Text[100]
    begin
        exit(TaxesPayablesTok);
    end;

    procedure GstPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GstPayableName()));
    end;

    procedure GstPayableName(): Text[100]
    begin
        exit(GstPayableTok);
    end;

    procedure GstReceivable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GstReceivableName()));
    end;

    procedure GstReceivableName(): Text[100]
    begin
        exit(GstReceivableTok);
    end;

    procedure GstClearing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GstClearingName()));
    end;

    procedure GstClearingName(): Text[100]
    begin
        exit(GstClearingTok);
    end;

    procedure GstRecon(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GstReconName()));
    end;

    procedure GstReconName(): Text[100]
    begin
        exit(GstReconTok);
    end;

    procedure WhtTaxPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WhtTaxPayableName()));
    end;

    procedure WhtTaxPayableName(): Text[100]
    begin
        exit(WhtTaxPayableTok);
    end;

    procedure WhtPrepaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WhtPrepaidName()));
    end;

    procedure WhtPrepaidName(): Text[100]
    begin
        exit(WhtPrepaidTok);
    end;

    procedure TaxesPayablesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesPayablesTotalName()));
    end;

    procedure TaxesPayablesTotalName(): Text[100]
    begin
        exit(TaxesPayablesTotalTok);
    end;

    procedure UnearnedRevenueOther(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnearnedRevenueOtherName()));
    end;

    procedure UnearnedRevenueOtherName(): Text[100]
    begin
        exit(UnearnedRevenueOtherTok);
    end;

    procedure FundsReceivedInAdvance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FundsReceivedInAdvanceName()));
    end;

    procedure FundsReceivedInAdvanceName(): Text[100]
    begin
        exit(FundsReceivedInAdvanceTok);
    end;

    procedure OtherCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCurrentLiabilitiesName()));
    end;

    procedure OtherCurrentLiabilitiesName(): Text[100]
    begin
        exit(OtherCurrentLiabilitiesTok);
    end;

    procedure TotalUnearnedRevenueOther(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalUnearnedRevenueOtherName()));
    end;

    procedure TotalUnearnedRevenueOtherName(): Text[100]
    begin
        exit(TotalUnearnedRevenueOtherTok);
    end;

    procedure NonCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonCurrentLiabilitiesName()));
    end;

    procedure NonCurrentLiabilitiesName(): Text[100]
    begin
        exit(NonCurrentLiabilitiesTok);
    end;

    procedure EmployeeProvisions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeeProvisionsName()));
    end;

    procedure EmployeeProvisionsName(): Text[100]
    begin
        exit(EmployeeProvisionsTok);
    end;

    procedure LongServiceLeave(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongServiceLeaveName()));
    end;

    procedure LongServiceLeaveName(): Text[100]
    begin
        exit(LongServiceLeaveTok);
    end;

    procedure TotalEmployeeProvisions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalEmployeeProvisionsName()));
    end;

    procedure TotalEmployeeProvisionsName(): Text[100]
    begin
        exit(TotalEmployeeProvisionsTok);
    end;

    procedure TotalNonCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalNonCurrentLiabilitiesName()));
    end;

    procedure TotalNonCurrentLiabilitiesName(): Text[100]
    begin
        exit(TotalNonCurrentLiabilitiesTok);
    end;

    procedure StockSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StockSalesName()));
    end;

    procedure StockSalesName(): Text[100]
    begin
        exit(StockSalesTok);
    end;

    procedure HireIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireIncomeName()));
    end;

    procedure HireIncomeName(): Text[100]
    begin
        exit(HireIncomeTok);
    end;

    procedure RentalIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalIncomeName()));
    end;

    procedure RentalIncomeName(): Text[100]
    begin
        exit(RentalIncomeTok);
    end;

    procedure SalesOfServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesOfServiceContractsName()));
    end;

    procedure SalesOfServiceContractsName(): Text[100]
    begin
        exit(SalesOfServiceContractsTok);
    end;

    procedure ServiceContractSale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceContractSaleName()));
    end;

    procedure ServiceContractSaleName(): Text[100]
    begin
        exit(ServiceContractSaleTok);
    end;

    procedure TotalSaleOfServContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSaleOfServContractsName()));
    end;

    procedure TotalSaleOfServContractsName(): Text[100]
    begin
        exit(TotalSaleOfServContractsTok);
    end;

    procedure FreightExpensesRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightExpensesRetailName()));
    end;

    procedure FreightExpensesRetailName(): Text[100]
    begin
        exit(FreightExpensesRetailTok);
    end;

    procedure DirectCostAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedRetailName()));
    end;

    procedure DirectCostAppliedRetailName(): Text[100]
    begin
        exit(DirectCostAppliedRetailTok);
    end;

    procedure OverheadAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedRetailName()));
    end;

    procedure OverheadAppliedRetailName(): Text[100]
    begin
        exit(OverheadAppliedRetailTok);
    end;

    procedure PurchaseVarianceRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceRetailName()));
    end;

    procedure PurchaseVarianceRetailName(): Text[100]
    begin
        exit(PurchaseVarianceRetailTok);
    end;

    procedure FreightExpensesRawMatCOGS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightExpensesRawMatCOGSName()));
    end;

    procedure FreightExpensesRawMatCOGSName(): Text[100]
    begin
        exit(FreightExpensesRawMatCOGSTok);
    end;

    procedure FreightExpensesRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightExpensesRawMatName()));
    end;

    procedure FreightExpensesRawMatName(): Text[100]
    begin
        exit(FreightExpensesRawMatTok);
    end;

    procedure DirectCostAppliedRawmat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedRawmatName()));
    end;

    procedure DirectCostAppliedRawmatName(): Text[100]
    begin
        exit(DirectCostAppliedRawmatTok);
    end;

    procedure OverheadAppliedRawmat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedRawmatName()));
    end;

    procedure OverheadAppliedRawmatName(): Text[100]
    begin
        exit(OverheadAppliedRawmatTok);
    end;

    procedure PurchaseVarianceRawmat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceRawmatName()));
    end;

    procedure PurchaseVarianceRawmatName(): Text[100]
    begin
        exit(PurchaseVarianceRawmatTok);
    end;

    procedure CostOfCapacities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfCapacitiesName()));
    end;

    procedure CostOfCapacitiesName(): Text[100]
    begin
        exit(CostOfCapacitiesTok);
    end;

    procedure CostOfCapacitiesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfCapacitiesBeginTotalName()));
    end;

    procedure CostOfCapacitiesBeginTotalName(): Text[100]
    begin
        exit(CostOfCapacitiesBeginTotalTok);
    end;

    procedure DirectCostAppliedCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedCapName()));
    end;

    procedure DirectCostAppliedCapName(): Text[100]
    begin
        exit(DirectCostAppliedCapTok);
    end;

    procedure OverheadAppliedCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedCapName()));
    end;

    procedure OverheadAppliedCapName(): Text[100]
    begin
        exit(OverheadAppliedCapTok);
    end;

    procedure PurchaseVarianceCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceCapName()));
    end;

    procedure PurchaseVarianceCapName(): Text[100]
    begin
        exit(PurchaseVarianceCapTok);
    end;

    procedure TotalCostOfCapacities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostOfCapacitiesName()));
    end;

    procedure TotalCostOfCapacitiesName(): Text[100]
    begin
        exit(TotalCostOfCapacitiesTok);
    end;

    procedure Variance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VarianceName()));
    end;

    procedure VarianceName(): Text[100]
    begin
        exit(VarianceTok);
    end;

    procedure MaterialVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialVarianceName()));
    end;

    procedure MaterialVarianceName(): Text[100]
    begin
        exit(MaterialVarianceTok);
    end;

    procedure CapacityVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapacityVarianceName()));
    end;

    procedure CapacityVarianceName(): Text[100]
    begin
        exit(CapacityVarianceTok);
    end;

    procedure SubcontractedVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedVarianceName()));
    end;

    procedure SubcontractedVarianceName(): Text[100]
    begin
        exit(SubcontractedVarianceTok);
    end;

    procedure CapOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapOverheadVarianceName()));
    end;

    procedure CapOverheadVarianceName(): Text[100]
    begin
        exit(CapOverheadVarianceTok);
    end;

    procedure MfgOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MfgOverheadVarianceName()));
    end;

    procedure MfgOverheadVarianceName(): Text[100]
    begin
        exit(MfgOverheadVarianceTok);
    end;

    procedure TotalVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalVarianceName()));
    end;

    procedure TotalVarianceName(): Text[100]
    begin
        exit(TotalVarianceTok);
    end;

    procedure AnnualLeaveExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnnualLeaveExpensesName()));
    end;

    procedure AnnualLeaveExpensesName(): Text[100]
    begin
        exit(AnnualLeaveExpensesTok);
    end;

    procedure Ebitda(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EbitdaName()));
    end;

    procedure EbitdaName(): Text[100]
    begin
        exit(EbitdaTok);
    end;

    procedure PurchaseWhtAdjustments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseWhtAdjustmentsName()));
    end;

    procedure PurchaseWhtAdjustmentsName(): Text[100]
    begin
        exit(PurchaseWhtAdjustmentsTok);
    end;

    procedure SalesWhtAdjustments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesWhtAdjustmentsName()));
    end;

    procedure SalesWhtAdjustmentsName(): Text[100]
    begin
        exit(SalesWhtAdjustmentsTok);
    end;

    procedure TotalGainsAndLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalGainsAndLossesName()));
    end;

    procedure TotalGainsAndLossesName(): Text[100]
    begin
        exit(TotalGainsAndLossesTok);
    end;

    procedure NiBefExtrItemsTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NiBefExtrItemsTaxesName()));
    end;

    procedure NiBefExtrItemsTaxesName(): Text[100]
    begin
        exit(NiBefExtrItemsTaxesTok);
    end;

    procedure IncomeTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeTaxesName()));
    end;

    procedure IncomeTaxesName(): Text[100]
    begin
        exit(IncomeTaxesTok);
    end;

    procedure TotalIncomeTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalIncomeTaxesName()));
    end;

    procedure TotalIncomeTaxesName(): Text[100]
    begin
        exit(TotalIncomeTaxesTok);
    end;

    procedure OtherComprehensiveNetIncomeTaxForThePeriod(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherComprehensiveNetIncomeTaxForThePeriodName()));
    end;

    procedure OtherComprehensiveNetIncomeTaxForThePeriodName(): Text[100]
    begin
        exit(OtherComprehensiveNetIncomeTaxForThePeriodTok);
    end;

    procedure OtherComprehensiveNetIncomeTaxForThePeriodBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherComprehensiveNetIncomeTaxForThePeriodBeginTotalName()));
    end;

    procedure OtherComprehensiveNetIncomeTaxForThePeriodBeginTotalName(): Text[100]
    begin
        exit(OtherComprehensiveNetIncomeTaxForThePeriodBeginTotalTok);
    end;

    procedure NetIncomeBeforeExtrItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetIncomeBeforeExtrItemsName()));
    end;

    procedure NetIncomeBeforeExtrItemsName(): Text[100]
    begin
        exit(NetIncomeBeforeExtrItemsTok);
    end;

    procedure TotalComprehensiveIncomeForThePeriod(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalComprehensiveIncomeForThePeriodName()));
    end;

    procedure TotalComprehensiveIncomeForThePeriodName(): Text[100]
    begin
        exit(TotalComprehensiveIncomeForThePeriodTok);
    end;

    procedure GainsandLossesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsandLossesBeginTotalName()));
    end;

    procedure GainsandLossesBeginTotalName(): Text[100]
    begin
        exit(GainsandLossesBeginTotalLbl);
    end;

    procedure MiscellaneousExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscellaneousExpenseName()));
    end;

    procedure MiscellaneousExpenseName(): Text[100]
    begin
        exit(MiscellaneousExpenseLbl);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        StmtOfFinancialPositionTok: Label 'STMT. OF FINANCIAL POSITION', MaxLength = 100;
        BankOtherTok: Label 'Bank, Other', MaxLength = 100;
        CustomersIntercompanyTok: Label 'Customers, Intercompany', MaxLength = 100;
        WipAccountFinishedGoodsTok: Label 'WIP Account, Finished goods', MaxLength = 100;
        TotalCurrentAssetsTok: Label 'Total Current Assets', MaxLength = 100;
        NonCurrentAssetsTok: Label 'Non-Current Assets', MaxLength = 100;
        FinancialAssetsTok: Label 'Financial Assets', MaxLength = 100;
        InvestmentsTok: Label 'Investments', MaxLength = 100;
        OtherFinancialAssetsTok: Label 'Other Financial assets', MaxLength = 100;
        TotalFinancialAssetsTok: Label 'Total Financial Assets', MaxLength = 100;
        OfficeEquipmentTok: Label 'Office Equipment', MaxLength = 100;
        OfficeEquipmentBeginTotalTok: Label 'Office Equipment,Begin Total', MaxLength = 100;
        OfficeEquipmentTotalTok: Label 'Office Equipment, Total', MaxLength = 100;
        IntangibleAssetsTok: Label 'Intangible Assets', MaxLength = 100;
        IntangibleAssetsBeginTotalTok: Label 'Intangible Assets,Begin Total', MaxLength = 100;
        AccAmortnOnIntangiblesTok: Label 'Acc. Amortn on Intangibles', MaxLength = 100;
        IntangibleAssetsTotalTok: Label 'Intangible Assets, Total', MaxLength = 100;
        RightToUseAssetsTok: Label 'Right to use assets', MaxLength = 100;
        RightToUseLeasesTok: Label 'Right to use leases', MaxLength = 100;
        AccAmortnOnRightOfUseLeasesTok: Label 'Acc. Amortn on Right of use  Leases', MaxLength = 100;
        RightToUseAssetsTotalTok: Label 'Right to use assets, Total', MaxLength = 100;
        TotalNonCurrentAssetsTok: Label 'Total Non Current Assets', MaxLength = 100;
        PrepaidServiceContractsTok: Label 'Prepaid Service Contracts', MaxLength = 100;
        DeferredRevenueTok: Label 'Deferred Revenue', MaxLength = 100;
        TradeAndOtherPayablesTok: Label 'Trade and Other Payables', MaxLength = 100;
        TradeAndOtherPayablesBeginTotalTok: Label 'Trade and Other Payables,Begin-Total', MaxLength = 100;
        VendorsIntercompanyTok: Label 'Vendors, Intercompany', MaxLength = 100;
        AccruedExpensesTok: Label 'Accrued Expenses', MaxLength = 100;
        ProvisionForIncomeTaxTok: Label 'Provision for Income Tax', MaxLength = 100;
        ProvisionForAnnualLeaveTok: Label 'Provision for Annual Leave', MaxLength = 100;
        SuperannuationClearingTok: Label 'Superannuation clearing', MaxLength = 100;
        PayrollClearingTok: Label 'Payroll clearing', MaxLength = 100;
        PayrollDeductionsTok: Label 'Payroll Deductions', MaxLength = 100;
        TaxesPayablesTok: Label 'Taxes Payables', MaxLength = 100;
        GstPayableTok: Label 'GST Payable', MaxLength = 100;
        GstReceivableTok: Label 'GST Receivable', MaxLength = 100;
        GstClearingTok: Label 'GST Clearing', MaxLength = 100;
        GstReconTok: Label 'GST Recon', MaxLength = 100;
        WhtTaxPayableTok: Label 'WHT Tax Payable', MaxLength = 100;
        WhtPrepaidTok: Label 'WHT Prepaid', MaxLength = 100;
        TaxesPayablesTotalTok: Label 'Taxes Payables, Total', MaxLength = 100;
        UnearnedRevenueOtherTok: Label 'Unearned Revenue & Other', MaxLength = 100;
        FundsReceivedInAdvanceTok: Label 'Funds received in advance', MaxLength = 100;
        OtherCurrentLiabilitiesTok: Label 'Other current liabilities', MaxLength = 100;
        TotalUnearnedRevenueOtherTok: Label 'Total Unearned Revenue & Other', MaxLength = 100;
        NonCurrentLiabilitiesTok: Label 'Non Current Liabilities', MaxLength = 100;
        EmployeeProvisionsTok: Label 'Employee Provisions', MaxLength = 100;
        LongServiceLeaveTok: Label 'Long service leave', MaxLength = 100;
        TotalEmployeeProvisionsTok: Label 'Total Employee Provisions ', MaxLength = 100;
        TotalNonCurrentLiabilitiesTok: Label 'Total Non Current Liabilities', MaxLength = 100;
        StockSalesTok: Label 'Stock Sales', MaxLength = 100;
        HireIncomeTok: Label 'Hire Income', MaxLength = 100;
        RentalIncomeTok: Label 'Rental Income', MaxLength = 100;
        SalesOfServiceContractsTok: Label 'Sales of Service Contracts', MaxLength = 100;
        ServiceContractSaleTok: Label 'Service Contract Sale', MaxLength = 100;
        TotalSaleOfServContractsTok: Label 'Total Sale of Serv. Contracts', MaxLength = 100;
        FreightExpensesRetailTok: Label 'Freight Expenses, Retail', MaxLength = 100;
        DirectCostAppliedRetailTok: Label 'Direct Cost Applied, Retail', MaxLength = 100;
        OverheadAppliedRetailTok: Label 'Overhead Applied, Retail', MaxLength = 100;
        PurchaseVarianceRetailTok: Label 'Purchase Variance, Retail', MaxLength = 100;
        DirectCostAppliedRawmatTok: Label 'Direct Cost Applied, Rawmat.', MaxLength = 100;
        OverheadAppliedRawmatTok: Label 'Overhead Applied, Rawmat.', MaxLength = 100;
        PurchaseVarianceRawmatTok: Label 'Purchase Variance, Rawmat.', MaxLength = 100;
        CostOfCapacitiesTok: Label 'Cost of Capacities', MaxLength = 100;
        CostOfCapacitiesBeginTotalTok: Label 'Cost of Capacities,Begin-Total', MaxLength = 100;
        DirectCostAppliedCapTok: Label 'Direct Cost Applied, Cap.', MaxLength = 100;
        OverheadAppliedCapTok: Label 'Overhead Applied, Cap.', MaxLength = 100;
        PurchaseVarianceCapTok: Label 'Purchase Variance, Cap.', MaxLength = 100;
        TotalCostOfCapacitiesTok: Label 'Total Cost of Capacities', MaxLength = 100;
        VarianceTok: Label 'Variance', MaxLength = 100;
        MaterialVarianceTok: Label 'Material Variance', MaxLength = 100;
        CapacityVarianceTok: Label 'Capacity Variance', MaxLength = 100;
        SubcontractedVarianceTok: Label 'Subcontracted Variance', MaxLength = 100;
        CapOverheadVarianceTok: Label 'Cap. Overhead Variance', MaxLength = 100;
        MfgOverheadVarianceTok: Label 'Mfg. Overhead Variance', MaxLength = 100;
        TotalVarianceTok: Label 'Total Variance', MaxLength = 100;
        FreightExpensesRawMatTok: Label 'Freight Expenses, Raw Mat.', MaxLength = 100;
        FreightExpensesRawMatCOGSTok: Label 'Freight Expenses, Raw Mat. COGS', MaxLength = 100;
        AnnualLeaveExpensesTok: Label 'Annual Leave Expenses', MaxLength = 100;
        EbitdaTok: Label 'EBITDA', MaxLength = 100;
        PurchaseWhtAdjustmentsTok: Label 'Purchase WHT Adjustments', MaxLength = 100;
        SalesWhtAdjustmentsTok: Label 'Sales WHT Adjustments', MaxLength = 100;
        TotalGainsAndLossesTok: Label 'TOTAL GAINS AND LOSSES', MaxLength = 100;
        NiBefExtrItemsTaxesTok: Label 'NI BEF. EXTR. ITEMS & TAXES', MaxLength = 100;
        IncomeTaxesTok: Label 'Income Taxes', MaxLength = 100;
        TotalIncomeTaxesTok: Label 'Total Income Taxes', MaxLength = 100;
        OtherComprehensiveNetIncomeTaxForThePeriodTok: Label 'Other comprehensive net income tax for the period', MaxLength = 100;
        OtherComprehensiveNetIncomeTaxForThePeriodBeginTotalTok: Label 'Other comprehensive net income tax for the period,Begin-Total', MaxLength = 100;
        NetIncomeBeforeExtrItemsTok: Label 'NET INCOME BEFORE EXTR. ITEMS', MaxLength = 100;
        TotalComprehensiveIncomeForThePeriodTok: Label 'Total comprehensive income for the period', MaxLength = 100;
        GainsandLossesBeginTotalLbl: Label 'Gains and Losses, Begin Total', MaxLength = 100;
        MiscellaneousExpenseLbl: Label 'Miscellaneous Expense', MaxLength = 100;
}