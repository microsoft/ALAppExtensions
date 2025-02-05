codeunit 11299 "Create SE GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '1510');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '2441');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '3051');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '4051');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '2610');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '2645');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '4192');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '4151');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '4160');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '4060');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '1460');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '1461')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '1450');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '1215');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '1216');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '1219');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '6450');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '7830');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '7891');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '7100');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '1433');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '1436');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '3057');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '3085');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '4065');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '4300');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforSE()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '1100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '1110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '1115');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '1116');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '1119');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsTotalName(), '1190');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '1200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '1210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '1215');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '1216');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '1219');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '1220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '1240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '1241');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '1245');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '1246');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '1249');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '1250');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '1260');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '1300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '1310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '1397');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '1398');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '1400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '1401');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '1411');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPName(), '1430');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesName(), '1431');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '1432');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '1433');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesTotalName(), '1434');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsName(), '1435');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), '1436');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '1437');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsTotalName(), '1438');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPTotalName(), '1449');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '1450');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '1451');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '1452');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '1460');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '1461');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '1499');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '1500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '1510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '1511');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '1520');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '1530');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '1599');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '1900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '1910');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '1920');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLCYName(), '1940');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '1941');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '1949');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '1998');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TOTALASSETSName(), '1999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LIABILITIESANDEQUITYName(), '2000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '2010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '2081');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '2085');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '2091');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomefortheYearName(), '2098');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '2099');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '2211');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesName(), '2300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '2330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '2352');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermBankLoansName(), '2359');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesTotalName(), '2399');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesName(), '2400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '2440');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '2441');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '2442');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '2449');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '2510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '2600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT25Name(), '2610');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25EUName(), '2615');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25Name(), '2640');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATTotalName(), '2650');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '2670');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '2671');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '2672');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '2674');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATPayableName(), '2679');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '2711');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '2718');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '2890');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '2990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesTotalName(), '2995');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '2997');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TOTALLIABILITIESANDEQUITYName(), '2999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.INCOMESTATEMENTName(), '3000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '3002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRetailName(), '3050');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '3051');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '3055');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), '3056');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '3057');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRetailName(), '3059');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRawMaterialsName(), '3060');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '3061');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '3065');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEUName(), '3066');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '3067');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRawMaterialsName(), '3069');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofResourcesName(), '3070');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '3071');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '3075');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), '3076');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '3077');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofResourcesName(), '3079');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofJobsName(), '3080');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '3081');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '3085');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofJobsName(), '3089');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '3090');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesandChargesRecDomName(), '3095');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '3098');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '3731');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscGrantedDecreasesName(), '3732');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '3740');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '3999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '4000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailName(), '4002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '4051');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '4055');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEUName(), '4056');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResaleSoldInterimName(), '4058');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailSoldName(), '4059');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '4060');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '4061');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '4065');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '4070');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '4080');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRetailName(), '4099');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsName(), '4100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '4151');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '4155');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEUName(), '4156');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMatSoldInterimName(), '4158');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsSoldName(), '4159');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '4160');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '4161');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '4165');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '4170');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '4180');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRawMaterialsName(), '4199');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesName(), '4200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '4250');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesUsedName(), '4260');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofResourcesName(), '4299');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '4300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '4599');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '4731');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscReceivedDecreasesName(), '4732');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '5100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityandHeatingName(), '5130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '5135');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CO2TaxName(), '5136');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '5160');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '5170');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '5199');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '5600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandMotorOilName(), '5611');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '5612');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '5613');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '5699');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '5710');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '5810');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '5900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '5910');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandPRName(), '5970');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '5999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '6200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandFaxName(), '6210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '6220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '6230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '6299');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '6351');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '6352');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalandAccountingServicesName(), '6420');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '6450');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '6500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '6540');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '6550');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '6560');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '6599');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '7000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '7010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '7090');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '7100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelrelatedItemsName(), '7200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '7210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelrelatedItemsName(), '7299');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '7400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '7590');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '7599');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationofFixedAssetsName(), '7800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '7820');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '7830');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '7834');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsandLossesName(), '7891');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '7899');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsofOperationsName(), '7990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '7995');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsfortheFiscalYearName(), '8010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXGainsName(), '8220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXLossesName(), '8221');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXGainsName(), '8231');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXLossesName(), '8234');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '8400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankBalancesName(), '8410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesfromCustomersName(), '8420');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargestoVendorsName(), '8422');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonRevolvingCreditName(), '8451');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankLoansName(), '8452');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '8453');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '8499');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '8710');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '8750');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NETINCOMEBEFORETAXESName(), '8900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '8910');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NETINCOMEName(), '8999');
        ContosoGLAccount.AddAccountForLocalization(ShipmentsnotinvoicedName(), '1793');
        ContosoGLAccount.AddAccountForLocalization(OutputVATrevVATliabilityName(), '2617');
        ContosoGLAccount.AddAccountForLocalization(SalesVAT12Name(), '2620');
        ContosoGLAccount.AddAccountForLocalization(SalesVAT6Name(), '2630');
        ContosoGLAccount.AddAccountForLocalization(OnlyVATName(), '2641');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVAT12Name(), '2642');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVAT12EUName(), '2645');
        ContosoGLAccount.AddAccountForLocalization(InputVATrevVATliabilityName(), '2647');
        ContosoGLAccount.AddAccountForLocalization(ReceiptsnotinvoicedName(), '2993');
        ModifyGLAccountForW1();
    end;

    local procedure ModifyGLAccountForW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchasePrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesPrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CustomerPrepaymentsVAT0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CustomerPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InvAdjmtInterimTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchaseVAT10EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchaseVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobSalesAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobSalesAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobSalesAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobCostAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobCostAdjmtRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobCostAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OtherOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OtherOperatingExpTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PaymentToleranceReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PmtTolReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalInterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PaymentToleranceGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PmtTolGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.NIBEFOREEXTRITEMSTAXESName(), '');

        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        GLAccountCategory: Record "G/L Account Category";
        CreateVATPostingGroupsSE: Codeunit "Create VAT Posting Groups SE";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        SubCategory: Text[80];
    begin
        SubCategory := Format(GLAccountCategoryMgt.GetCurrentAssets(), 80);
        ContosoGLAccount.InsertGLAccount(Shipmentsnotinvoiced(), ShipmentsnotinvoicedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CurrentAssetsTotal(), CreateGLAccount.CurrentAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CurrentAssets() + '..' + CreateGLAccount.CurrentAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CurrentAssets(), CreateGLAccount.CurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCash(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GiroAccount(), CreateGLAccount.GiroAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BankLCY(), CreateGLAccount.BankLCYName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BankCurrencies(), CreateGLAccount.BankCurrenciesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAR(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersDomestic(), CreateGLAccount.CustomersDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersForeign(), CreateGLAccount.CustomersForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OutputVATrevVATliability(), OutputVATrevVATliabilityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OnlyVAT(), OnlyVATName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroupsSE.Only(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchaseVAT25(), CreateGLAccount.PurchaseVAT25Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVAT12(), PurchaseVAT12Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVAT12EU(), PurchaseVAT12EUName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InputVATrevVATliability(), InputVATrevVATliabilityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInventory(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterialsInterim(), CreateGLAccount.RawMaterialsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobSales(), CreateGLAccount.WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoicedJobSales(), CreateGLAccount.InvoicedJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobCosts(), CreateGLAccount.WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccruedJobCosts(), CreateGLAccount.AccruedJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoodsInterim(), CreateGLAccount.FinishedGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PrimoInventory(), CreateGLAccount.PrimoInventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItemsInterim(), CreateGLAccount.ResaleItemsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetFixedAssets(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FixedAssetsTotal(), CreateGLAccount.FixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.FixedAssets() + '..' + CreateGLAccount.FixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAccumDeprec(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDepreciationBuildings(), CreateGLAccount.AccumDepreciationBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDeprOperEquip(), CreateGLAccount.AccumDeprOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDepreciationVehicles(), CreateGLAccount.AccumDepreciationVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilities(), CreateGLAccount.TotalLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LIABILITIESANDEQUITY() + '..' + CreateGLAccount.TotalLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilitiesAndEquity(), CreateGLAccount.TotalLiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, CreateGLAccount.LIABILITIESANDEQUITY() + '..' + CreateGLAccount.TOTALLIABILITIESANDEQUITY() + '|' + CreateGLAccount.INCOMESTATEMENT() + '..' + CreateGLAccount.NETINCOME(), Enum::"General Posting Type"::" ", '', '', false, false, true);

        SubCategory := Format(GLAccountCategoryMgt.GetTravelExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Travel(), CreateGLAccount.TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsSE.NoVat(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetVehicleExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VehicleExpenses(), CreateGLAccount.VehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GasolineandMotorOil(), CreateGLAccount.GasolineandMotorOilName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RegistrationFees(), CreateGLAccount.RegistrationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsSE.NoVat(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RepairsandMaintenance(), CreateGLAccount.RepairsandMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalVehicleExpenses(), CreateGLAccount.TotalVehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.VehicleExpenses() + '..' + CreateGLAccount.TotalVehicleExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetBadDebtExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BadDebtExpenses(), CreateGLAccount.BadDebtExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInterestExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestonBankBalances(), CreateGLAccount.InterestonBankBalancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsSE.NoVat(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCOGSDiscountsGranted(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtDiscGrantedDecreases(), CreateGLAccount.PmtDiscGrantedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtDiscReceivedDecreases(), CreateGLAccount.PmtDiscReceivedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeService(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesDom(), CreateGLAccount.SalesResourcesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesEU(), CreateGLAccount.SalesResourcesEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesExport(), CreateGLAccount.SalesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedResources(), CreateGLAccount.JobSalesAppliedResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCOGSLabor(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofResources(), CreateGLAccount.CostofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedResources(), CreateGLAccount.JobCostAppliedResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeSalesDiscounts(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PaymentDiscountsReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetDistrToShareholders(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DividendsfortheFiscalYear(), CreateGLAccount.DividendsfortheFiscalYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetJobsCost(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedRetail(), CreateGLAccount.JobCostAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedRawMat(), CreateGLAccount.JobCostAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VacationCompensationPayable(), CreateGLAccount.VacationCompensationPayableName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.EmployeesPayable(), CreateGLAccount.EmployeesPayableName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PersonnelrelatedItems(), CreateGLAccount.PersonnelrelatedItemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalPersonnelrelatedItems(), CreateGLAccount.TotalPersonnelrelatedItemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PersonnelrelatedItems() + '..' + CreateGLAccount.TotalPersonnelrelatedItems(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetLongTermLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RevolvingCredit(), CreateGLAccount.RevolvingCreditName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WithholdingTaxesPayable(), CreateGLAccount.WithholdingTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Equity, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Stockholder(), CreateGLAccount.StockholderName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCommonStock(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CapitalStock(), CreateGLAccount.CapitalStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalStockholder(), CreateGLAccount.TotalStockholderName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, CreateGLAccount.Stockholder() + '..' + CreateGLAccount.TotalStockholder() + '|' + CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetRetEarnings(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RetainedEarnings(), CreateGLAccount.RetainedEarningsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncomefortheYear(), CreateGLAccount.NetIncomefortheYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsSE.NoVat(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.UnrealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RealizedFXGains(), CreateGLAccount.RealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAdvertisingExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SellingExpenses(), CreateGLAccount.SellingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSellingExpenses(), CreateGLAccount.TotalSellingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SellingExpenses() + '..' + CreateGLAccount.TotalSellingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetTaxExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ElectricityTax(), CreateGLAccount.ElectricityTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NaturalGasTax(), CreateGLAccount.NaturalGasTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CoalTax(), CreateGLAccount.CoalTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WaterTax(), CreateGLAccount.WaterTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FuelTax(), CreateGLAccount.FuelTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CO2Tax(), CreateGLAccount.CO2TaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInventory(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobWIP(), CreateGLAccount.JobWIPName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPSales(), CreateGLAccount.WIPSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPSalesTotal(), CreateGLAccount.WIPSalesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.WIPSales() + '..' + CreateGLAccount.WIPSalesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPCosts(), CreateGLAccount.WIPCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPCostsTotal(), CreateGLAccount.WIPCostsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.WIPCosts() + '..' + CreateGLAccount.WIPCostsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobWIPTotal(), CreateGLAccount.JobWIPTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.JobWIP() + '..' + CreateGLAccount.JobWIPTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::"Cost of Goods Sold", 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cost(), CreateGLAccount.CostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.CostofResaleSoldInterimName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRetail(), CreateGLAccount.CostofRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailDom(), CreateGLAccount.PurchRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailExport(), CreateGLAccount.PurchRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailEU(), CreateGLAccount.PurchRetailEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofRetailSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpensesRetail(), CreateGLAccount.DeliveryExpensesRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherCostsofOperations(), CreateGLAccount.OtherCostsofOperationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimRetail(), CreateGLAccount.InvAdjmtInterimRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCurrentLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeferredTaxes(), CreateGLAccount.DeferredTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CorporateTaxesPayable(), CreateGLAccount.CorporateTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsPayable(), CreateGLAccount.AccountsPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsDomestic(), CreateGLAccount.VendorsDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsForeign(), CreateGLAccount.VendorsForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesVAT25(), CreateGLAccount.SalesVAT25Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SupplementaryTaxesPayable(), CreateGLAccount.SupplementaryTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchaseVAT25EU(), CreateGLAccount.PurchaseVAT25EUName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVAT12(), SalesVAT12Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVAT6(), SalesVAT6Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VATTotal(), CreateGLAccount.VATTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.InvAdjmtInterim() + '..' + CreateGLAccount.VATTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VATPayable(), CreateGLAccount.VATPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilities(), CreateGLAccount.OtherLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilitiesTotal(), CreateGLAccount.OtherLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OtherLiabilities() + '..' + CreateGLAccount.OtherLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Receiptsnotinvoiced(), ReceiptsnotinvoicedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ShorttermLiabilitiesTotal(), CreateGLAccount.ShorttermLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.ShorttermLiabilities() + '..' + CreateGLAccount.ShorttermLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalCost(), CreateGLAccount.TotalCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Cost() + '..' + CreateGLAccount.TotalCost(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AdministrativeExpenses(), CreateGLAccount.AdministrativeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PhoneandFax(), CreateGLAccount.PhoneandFaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsSE.NoVat(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Miscellaneous(), CreateGLAccount.MiscellaneousName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LegalandAccountingServices(), CreateGLAccount.LegalandAccountingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GainsandLosses(), CreateGLAccount.GainsandLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.UnrealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RealizedFXLosses(), CreateGLAccount.RealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetEquipment(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LandandBuildings(), CreateGLAccount.LandandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncreasesduringtheYearBuildings(), CreateGLAccount.IncreasesduringtheYearBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DecreasesduringtheYearBuildings(), CreateGLAccount.DecreasesduringtheYearBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OperatingEquipment(), CreateGLAccount.OperatingEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DecreasesduringtheYearOperEquip(), CreateGLAccount.DecreasesduringtheYearOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Vehicles(), CreateGLAccount.VehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DecreasesduringtheYearVehicles(), CreateGLAccount.DecreasesduringtheYearVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeProdSales(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailDom(), CreateGLAccount.SalesRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailExport(), CreateGLAccount.SalesRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedRetail(), CreateGLAccount.JobSalesAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsDom(), CreateGLAccount.SalesRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsEU(), CreateGLAccount.SalesRawMaterialsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsExport(), CreateGLAccount.SalesRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedRawMat(), CreateGLAccount.JobSalesAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCOGSMaterials(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsDom(), CreateGLAccount.PurchRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsExport(), CreateGLAccount.PurchRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsEU(), CreateGLAccount.PurchRawMaterialsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRawMatSoldInterim(), CreateGLAccount.CostofRawMatSoldInterimName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryAdjmtRawMat(), CreateGLAccount.InventoryAdjmtRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimRawMat(), CreateGLAccount.InvAdjmtInterimRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRawMaterialsSold(), CreateGLAccount.CostofRawMaterialsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LiabilitiesAndEquity(), CreateGLAccount.LiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchasePrepaymentsTotal(), AccountsPayableLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Assets(), CreateGLAccount.AssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
    end;

    procedure ShipmentsnotinvoicedName(): Text[100]
    begin
        exit(ShipmentsnotinvoicedTok);
    end;

    procedure OutputVATrevVATliabilityName(): Text[100]
    begin
        exit(OutputVATrevVATliabilityTok);
    end;

    procedure SalesVAT12Name(): Text[100]
    begin
        exit(SalesVAT12Tok);
    end;

    procedure SalesVAT6Name(): Text[100]
    begin
        exit(SalesVAT6Tok);
    end;

    procedure OnlyVATName(): Text[100]
    begin
        exit(OnlyVATTok);
    end;

    procedure PurchaseVAT12Name(): Text[100]
    begin
        exit(PurchaseVAT12Tok);
    end;

    procedure PurchaseVAT12EUName(): Text[100]
    begin
        exit(PurchaseVAT12EUTok);
    end;

    procedure InputVATrevVATliabilityName(): Text[100]
    begin
        exit(InputVATrevVATliabilityTok);
    end;

    procedure ReceiptsnotinvoicedName(): Text[100]
    begin
        exit(ReceiptsnotinvoicedTok);
    end;

    procedure Shipmentsnotinvoiced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShipmentsnotinvoicedName()));
    end;

    procedure OutputVATrevVATliability(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutputVATrevVATliabilityName()));
    end;

    procedure SalesVAT12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVAT12Name()));
    end;

    procedure SalesVAT6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVAT6Name()));
    end;

    procedure OnlyVAT(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OnlyVATName()));
    end;

    procedure PurchaseVAT12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVAT12Name()));
    end;

    procedure PurchaseVAT12EU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVAT12EUName()));
    end;

    procedure InputVATrevVATliability(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InputVATrevVATliabilityName()));
    end;

    procedure Receiptsnotinvoiced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceiptsnotinvoicedName()));
    end;


    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        ShipmentsnotinvoicedTok: Label 'Shipments not invoiced', MaxLength = 100;
        OutputVATrevVATliabilityTok: Label 'Output VAT rev. VAT liability', MaxLength = 100;
        SalesVAT12Tok: Label 'Sales VAT 12 %', MaxLength = 100;
        SalesVAT6Tok: Label 'Sales VAT 6%', MaxLength = 100;
        OnlyVATTok: Label 'Only VAT', MaxLength = 100;
        PurchaseVAT12Tok: Label 'Purchase VAT 12 %', MaxLength = 100;
        PurchaseVAT12EUTok: Label 'Purchase VAT 12 % EU';
        InputVATrevVATliabilityTok: Label 'Input VAT rev. VAT liability', MaxLength = 100;
        ReceiptsnotinvoicedTok: Label 'Receipts not invoiced', MaxLength = 100;
        AccountsPayableLbl: Label 'Accounts Payable', MaxLength = 100;
}