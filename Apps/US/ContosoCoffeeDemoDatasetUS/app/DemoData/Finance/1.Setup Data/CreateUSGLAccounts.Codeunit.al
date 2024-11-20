codeunit 10499 "Create US GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '15110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '22100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '40140');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '14140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '14110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '14140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '14110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '14140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '14110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '14110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '14110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '50110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '50110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '14140');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '40430');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '50210');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '50210');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '14130');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '14210');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '12210');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '17200');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(DepreciationFixedAssetsName(), '82000');
        ContosoGLAccount.AddAccountForLocalization(GoodwillName(), '11300');
        ContosoGLAccount.AddAccountForLocalization(BuildingName(), '12110');
        ContosoGLAccount.AddAccountForLocalization(DepreciationLandandPropertyName(), '81000');
        ContosoGLAccount.AddAccountForLocalization(LandName(), '12130');
        ContosoGLAccount.AddAccountForLocalization(CarsandOtherTransportEquipmentsName(), '12230');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '14250');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '14230');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforUS()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BALANCESHEETName(), '10000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ASSETSName(), '10001');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '12000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '14130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '14110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '14220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), '14230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '17100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TOTALASSETSName(), '19999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '72140');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesName(), '21000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '22600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '29999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.INCOMESTATEMENTName(), '40000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofResourcesName(), '40200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '40410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '64100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '63100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '62100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '71100');
        ContosoGLAccount.AddAccountForLocalization(InterestIncomeName(), '40330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '40920');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '67200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NETINCOMEName(), '99999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResaleSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMatSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLCYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LIABILITIESANDEQUITYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomefortheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), '');
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
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsfortheFiscalYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TOTALLIABILITIESANDEQUITYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesandChargesRecDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesUsedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityandHeatingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandFaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandPRName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandMotorOilName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalandAccountingServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationofFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsandLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsofOperationsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankBalancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesfromCustomersName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonRevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargestoVendorsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NIBEFOREEXTRITEMSTAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NETINCOMEBEFORETAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '18100');
        ContosoGLAccount.AddAccountForLocalization(CostofMaterialsName(), '50110');
        ContosoGLAccount.AddAccountForLocalization(ResaleofGoodsName(), '40140');
        ContosoGLAccount.AddAccountForLocalization(SalesofServiceWorkName(), '40440');
        ContosoGLAccount.AddAccountForLocalization(DiscountsandAllowancesName(), '40910');
        ContosoGLAccount.AddAccountForLocalization(OtherExternalServicesName(), '68190');
        ContosoGLAccount.AddAccountForLocalization(PurchaseDiscountsName(), '68290');
        ContosoGLAccount.AddAccountForLocalization(CostofLaborName(), '50210');
        ContosoGLAccount.AddAccountForLocalization(PayableInvoiceRoundingName(), '67300');
        ContosoGLAccount.AddAccountForLocalization(IncomeName(), '40001');
        ContosoGLAccount.AddAccountForLocalization(SalesofGoodsName(), '40100');
        ContosoGLAccount.AddAccountForLocalization(SaleofFinishedGoodsName(), '40130');
        ContosoGLAccount.AddAccountForLocalization(SaleofRawMaterialsName(), '40110');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesofGoodsName(), '40199');
        ContosoGLAccount.AddAccountForLocalization(SaleofResourcesName(), '40210');
        ContosoGLAccount.AddAccountForLocalization(SaleofSubcontractingName(), '40220');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesofResourcesName(), '40299');
        ContosoGLAccount.AddAccountForLocalization(AdditionalRevenueName(), '40300');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromSecuritiesName(), '40310');
        ContosoGLAccount.AddAccountForLocalization(ManagementFeeRevenueName(), '40320');
        ContosoGLAccount.AddAccountForLocalization(CurrencyGainsName(), '40380');
        ContosoGLAccount.AddAccountForLocalization(OtherIncidentalRevenueName(), '40390');
        ContosoGLAccount.AddAccountForLocalization(TotalAdditionalRevenueName(), '40399');
        ContosoGLAccount.AddAccountForLocalization(JobsandServicesName(), '40400');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedName(), '40420');
        ContosoGLAccount.AddAccountForLocalization(SalesofServiceContractsName(), '40430');
        ContosoGLAccount.AddAccountForLocalization(TotalJobsandServicesName(), '40499');
        ContosoGLAccount.AddAccountForLocalization(RevenueReductionsName(), '40900');
        ContosoGLAccount.AddAccountForLocalization(SalesDiscountsName(), '40910');
        ContosoGLAccount.AddAccountForLocalization(SalesInvoiceRoundingName(), '40920');
        ContosoGLAccount.AddAccountForLocalization(PaymentToleranceandAllowancesName(), '40930');
        ContosoGLAccount.AddAccountForLocalization(SalesReturnsName(), '40940');
        ContosoGLAccount.AddAccountForLocalization(TotalRevenueReductionsName(), '40999');
        ContosoGLAccount.AddAccountForLocalization(TotalIncomeName(), '49990');
        ContosoGLAccount.AddAccountForLocalization(CostofGoodsSoldName(), '50001');
        ContosoGLAccount.AddAccountForLocalization(CostofGoodsName(), '50100');
        ContosoGLAccount.AddAccountForLocalization(CostofMaterialsProjectsName(), '50120');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofGoodsName(), '50199');
        ContosoGLAccount.AddAccountForLocalization(CostofResourcesandServicesName(), '50200');
        ContosoGLAccount.AddAccountForLocalization(CostofLaborProjectsName(), '50220');
        ContosoGLAccount.AddAccountForLocalization(CostofLaborWarrantyContractName(), '50230');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofResourcesName(), '50299');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedWorkName(), '50400');
        ContosoGLAccount.AddAccountForLocalization(CostofVariancesName(), '50500');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofGoodsSoldName(), '59990');
        ContosoGLAccount.AddAccountForLocalization(ExpensesName(), '60001');
        ContosoGLAccount.AddAccountForLocalization(FacilityExpensesName(), '60002');
        ContosoGLAccount.AddAccountForLocalization(RentalFacilitiesName(), '60100');
        ContosoGLAccount.AddAccountForLocalization(RentLeasesName(), '60110');
        ContosoGLAccount.AddAccountForLocalization(ElectricityforRentalName(), '60120');
        ContosoGLAccount.AddAccountForLocalization(HeatingforRentalName(), '60130');
        ContosoGLAccount.AddAccountForLocalization(WaterandSewerageforRentalName(), '60140');
        ContosoGLAccount.AddAccountForLocalization(CleaningandWasteforRentalName(), '60150');
        ContosoGLAccount.AddAccountForLocalization(RepairsandMaintenanceforRentalName(), '60160');
        ContosoGLAccount.AddAccountForLocalization(InsurancesRentalName(), '60170');
        ContosoGLAccount.AddAccountForLocalization(OtherRentalExpensesName(), '60190');
        ContosoGLAccount.AddAccountForLocalization(TotalRentalFacilitiesName(), '60199');
        ContosoGLAccount.AddAccountForLocalization(PropertyExpensesName(), '60200');
        ContosoGLAccount.AddAccountForLocalization(SiteFeesLeasesName(), '60210');
        ContosoGLAccount.AddAccountForLocalization(ElectricityforPropertyName(), '60220');
        ContosoGLAccount.AddAccountForLocalization(HeatingforPropertyName(), '60230');
        ContosoGLAccount.AddAccountForLocalization(WaterandSewerageforPropertyName(), '60240');
        ContosoGLAccount.AddAccountForLocalization(CleaningandWasteforPropertyName(), '60250');
        ContosoGLAccount.AddAccountForLocalization(RepairsandMaintenanceforPropertyName(), '60260');
        ContosoGLAccount.AddAccountForLocalization(InsurancesPropertyName(), '60270');
        ContosoGLAccount.AddAccountForLocalization(OtherPropertyExpensesName(), '60290');
        ContosoGLAccount.AddAccountForLocalization(TotalPropertyExpensesName(), '60299');
        ContosoGLAccount.AddAccountForLocalization(TotalFacilityExpensesName(), '60999');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetsLeasesName(), '61000');
        ContosoGLAccount.AddAccountForLocalization(HireofMachineryName(), '61100');
        ContosoGLAccount.AddAccountForLocalization(HireofComputersName(), '61200');
        ContosoGLAccount.AddAccountForLocalization(HireofOtherFixedAssetsName(), '61300');
        ContosoGLAccount.AddAccountForLocalization(TotalFixedAssetLeasesName(), '61999');
        ContosoGLAccount.AddAccountForLocalization(LogisticsExpensesName(), '62000');
        ContosoGLAccount.AddAccountForLocalization(PassengerCarCostsName(), '62110');
        ContosoGLAccount.AddAccountForLocalization(TruckCostsName(), '62120');
        ContosoGLAccount.AddAccountForLocalization(OtherVehicleExpensesName(), '62190');
        ContosoGLAccount.AddAccountForLocalization(TotalVehicleExpensesName(), '62199');
        ContosoGLAccount.AddAccountForLocalization(FreightCostsName(), '62200');
        ContosoGLAccount.AddAccountForLocalization(FreightFeesForGoodsName(), '62210');
        ContosoGLAccount.AddAccountForLocalization(CustomsandForwardingName(), '62220');
        ContosoGLAccount.AddAccountForLocalization(FreightFeesProjectsName(), '62230');
        ContosoGLAccount.AddAccountForLocalization(TotalFreightCostsName(), '62299');
        ContosoGLAccount.AddAccountForLocalization(TravelExpensesName(), '62300');
        ContosoGLAccount.AddAccountForLocalization(TicketsName(), '62310');
        ContosoGLAccount.AddAccountForLocalization(RentalVehiclesName(), '62320');
        ContosoGLAccount.AddAccountForLocalization(BoardandLodgingName(), '62330');
        ContosoGLAccount.AddAccountForLocalization(OtherTravelExpensesName(), '62340');
        ContosoGLAccount.AddAccountForLocalization(TotalTravelExpensesName(), '62399');
        ContosoGLAccount.AddAccountForLocalization(TotalLogisticsExpensesName(), '62999');
        ContosoGLAccount.AddAccountForLocalization(MarketingandSalesName(), '63000');
        ContosoGLAccount.AddAccountForLocalization(AdvertisementDevelopmentName(), '63110');
        ContosoGLAccount.AddAccountForLocalization(OutdoorandTransportationAdsName(), '63120');
        ContosoGLAccount.AddAccountForLocalization(AdMatterandDirectMailingsName(), '63130');
        ContosoGLAccount.AddAccountForLocalization(ConferenceExhibitionSponsorshipName(), '63140');
        ContosoGLAccount.AddAccountForLocalization(SamplesContestsGiftsName(), '63150');
        ContosoGLAccount.AddAccountForLocalization(FilmTVRadioInternetAdsName(), '63160');
        ContosoGLAccount.AddAccountForLocalization(PRandAgencyFeesName(), '63170');
        ContosoGLAccount.AddAccountForLocalization(OtherAdvertisingFeesName(), '63190');
        ContosoGLAccount.AddAccountForLocalization(TotalAdvertisingName(), '63199');
        ContosoGLAccount.AddAccountForLocalization(OtherMarketingExpensesName(), '63200');
        ContosoGLAccount.AddAccountForLocalization(CatalogsPriceListsName(), '63210');
        ContosoGLAccount.AddAccountForLocalization(TradePublicationsName(), '63220');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherMarketingExpensesName(), '63399');
        ContosoGLAccount.AddAccountForLocalization(SalesExpensesName(), '63400');
        ContosoGLAccount.AddAccountForLocalization(CreditCardChargesName(), '63410');
        ContosoGLAccount.AddAccountForLocalization(BusinessEntertainingDeductibleName(), '63420');
        ContosoGLAccount.AddAccountForLocalization(BusinessEntertainingNonDeductibleName(), '63430');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesExpensesName(), '63499');
        ContosoGLAccount.AddAccountForLocalization(TotalMarketingandSalesName(), '63999');
        ContosoGLAccount.AddAccountForLocalization(OfficeExpensesName(), '64000');
        ContosoGLAccount.AddAccountForLocalization(PhoneServicesName(), '64200');
        ContosoGLAccount.AddAccountForLocalization(DataServicesName(), '64300');
        ContosoGLAccount.AddAccountForLocalization(PostalFeesName(), '64400');
        ContosoGLAccount.AddAccountForLocalization(ConsumableExpensibleHardwareName(), '64500');
        ContosoGLAccount.AddAccountForLocalization(SoftwareandSubscriptionFeesName(), '64600');
        ContosoGLAccount.AddAccountForLocalization(TotalOfficeExpensesName(), '64999');
        ContosoGLAccount.AddAccountForLocalization(InsurancesandRisksName(), '65000');
        ContosoGLAccount.AddAccountForLocalization(CorporateInsuranceName(), '65100');
        ContosoGLAccount.AddAccountForLocalization(DamagesPaidName(), '65200');
        ContosoGLAccount.AddAccountForLocalization(BadDebtLossesName(), '65300');
        ContosoGLAccount.AddAccountForLocalization(SecurityServicesName(), '65400');
        ContosoGLAccount.AddAccountForLocalization(OtherRiskExpensesName(), '65900');
        ContosoGLAccount.AddAccountForLocalization(TotalInsurancesandRisksName(), '65999');
        ContosoGLAccount.AddAccountForLocalization(ManagementandAdminName(), '66000');
        ContosoGLAccount.AddAccountForLocalization(ManagementName(), '66100');
        ContosoGLAccount.AddAccountForLocalization(RemunerationtoDirectorsName(), '66110');
        ContosoGLAccount.AddAccountForLocalization(ManagementFeesName(), '66120');
        ContosoGLAccount.AddAccountForLocalization(AnnualInterrimReportsName(), '66130');
        ContosoGLAccount.AddAccountForLocalization(AnnualGeneralMeetingName(), '66140');
        ContosoGLAccount.AddAccountForLocalization(AuditandAuditServicesName(), '66150');
        ContosoGLAccount.AddAccountForLocalization(TaxAdvisoryServicesName(), '66160');
        ContosoGLAccount.AddAccountForLocalization(TotalManagementFeesName(), '66199');
        ContosoGLAccount.AddAccountForLocalization(TotalManagementandAdminName(), '66999');
        ContosoGLAccount.AddAccountForLocalization(BankingandInterestName(), '67000');
        ContosoGLAccount.AddAccountForLocalization(BankingFeesName(), '67100');
        ContosoGLAccount.AddAccountForLocalization(TotalBankingandInterestName(), '67999');
        ContosoGLAccount.AddAccountForLocalization(ExternalServicesExpensesName(), '68000');
        ContosoGLAccount.AddAccountForLocalization(ExternalServicesName(), '68100');
        ContosoGLAccount.AddAccountForLocalization(AccountingServicesName(), '68110');
        ContosoGLAccount.AddAccountForLocalization(ITServicesName(), '68120');
        ContosoGLAccount.AddAccountForLocalization(MediaServicesName(), '68130');
        ContosoGLAccount.AddAccountForLocalization(ConsultingServicesName(), '68140');
        ContosoGLAccount.AddAccountForLocalization(LegalFeesandAttorneyServicesName(), '68150');
        ContosoGLAccount.AddAccountForLocalization(TotalExternalServicesName(), '68199');
        ContosoGLAccount.AddAccountForLocalization(OtherExternalExpensesName(), '68200');
        ContosoGLAccount.AddAccountForLocalization(LicenseFeesRoyaltiesName(), '68210');
        ContosoGLAccount.AddAccountForLocalization(TrademarksPatentsName(), '68220');
        ContosoGLAccount.AddAccountForLocalization(AssociationFeesName(), '68230');
        ContosoGLAccount.AddAccountForLocalization(MiscExternalExpensesName(), '68280');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherExternalExpensesName(), '68299');
        ContosoGLAccount.AddAccountForLocalization(TotalExternalServicesExpensesName(), '68999');
        ContosoGLAccount.AddAccountForLocalization(PersonnelName(), '70000');
        ContosoGLAccount.AddAccountForLocalization(WagesandSalariesName(), '71000');
        ContosoGLAccount.AddAccountForLocalization(HourlyWagesName(), '71110');
        ContosoGLAccount.AddAccountForLocalization(OvertimeWagesName(), '71120');
        ContosoGLAccount.AddAccountForLocalization(BonusesName(), '71130');
        ContosoGLAccount.AddAccountForLocalization(CommissionsPaidName(), '71140');
        ContosoGLAccount.AddAccountForLocalization(PTOAccruedName(), '71150');
        ContosoGLAccount.AddAccountForLocalization(TotalWagesandSalariesName(), '71999');
        ContosoGLAccount.AddAccountForLocalization(BenefitsPensionName(), '72000');
        ContosoGLAccount.AddAccountForLocalization(BenefitsName(), '72100');
        ContosoGLAccount.AddAccountForLocalization(TrainingCostsName(), '72110');
        ContosoGLAccount.AddAccountForLocalization(HealthCareContributionsName(), '72120');
        ContosoGLAccount.AddAccountForLocalization(EntertainmentofPersonnelName(), '72130');
        ContosoGLAccount.AddAccountForLocalization(MandatoryClothingExpensesName(), '72150');
        ContosoGLAccount.AddAccountForLocalization(OtherCashRemunerationBenefitsName(), '72160');
        ContosoGLAccount.AddAccountForLocalization(TotalBenefitsName(), '72199');
        ContosoGLAccount.AddAccountForLocalization(PensionName(), '72200');
        ContosoGLAccount.AddAccountForLocalization(PensionFeesandRecurringCostsName(), '72210');
        ContosoGLAccount.AddAccountForLocalization(EmployerContributionsName(), '72220');
        ContosoGLAccount.AddAccountForLocalization(TotalPensionName(), '72299');
        ContosoGLAccount.AddAccountForLocalization(TotalBenefitsPensionName(), '72999');
        ContosoGLAccount.AddAccountForLocalization(InsurancesPersonnelName(), '73000');
        ContosoGLAccount.AddAccountForLocalization(HealthInsuranceName(), '73100');
        ContosoGLAccount.AddAccountForLocalization(DentalInsuranceName(), '73200');
        ContosoGLAccount.AddAccountForLocalization(WorkersCompensationName(), '73300');
        ContosoGLAccount.AddAccountForLocalization(LifeInsuranceName(), '73400');
        ContosoGLAccount.AddAccountForLocalization(TotalInsurancesPersonnelName(), '73999');
        ContosoGLAccount.AddAccountForLocalization(PersonnelTaxesName(), '74000');
        ContosoGLAccount.AddAccountForLocalization(FederalPersonnelTaxesName(), '74100');
        ContosoGLAccount.AddAccountForLocalization(FederalWithholdingExpenseName(), '74110');
        ContosoGLAccount.AddAccountForLocalization(FICAExpenseName(), '74120');
        ContosoGLAccount.AddAccountForLocalization(FUTAExpenseName(), '74130');
        ContosoGLAccount.AddAccountForLocalization(MedicareExpenseName(), '74140');
        ContosoGLAccount.AddAccountForLocalization(OtherFederalExpenseName(), '74190');
        ContosoGLAccount.AddAccountForLocalization(TotalFederalPersonnelTaxesName(), '74399');
        ContosoGLAccount.AddAccountForLocalization(StatePersonnelTaxesName(), '74400');
        ContosoGLAccount.AddAccountForLocalization(StateWithholdingExpenseName(), '74410');
        ContosoGLAccount.AddAccountForLocalization(SUTAExpenseName(), '74420');
        ContosoGLAccount.AddAccountForLocalization(TotalStatePersonnelTaxesName(), '74599');
        ContosoGLAccount.AddAccountForLocalization(TotalPersonnelTaxesName(), '74999');
        ContosoGLAccount.AddAccountForLocalization(TotalPersonnelName(), '79999');
        ContosoGLAccount.AddAccountForLocalization(DepreciationName(), '80000');
        ContosoGLAccount.AddAccountForLocalization(DepreciationLandandPropertyName(), '81000');
        ContosoGLAccount.AddAccountForLocalization(DepreciationFixedAssetsName(), '82000');
        ContosoGLAccount.AddAccountForLocalization(TotalDepreciationName(), '89999');
        ContosoGLAccount.AddAccountForLocalization(MiscExpensesName(), '90000');
        ContosoGLAccount.AddAccountForLocalization(CurrencyLossesName(), '91000');
        ContosoGLAccount.AddAccountForLocalization(TotalMiscExpensesName(), '91999');
        ContosoGLAccount.AddAccountForLocalization(TotalExpensesName(), '98990');
        ContosoGLAccount.AddAccountForLocalization(IntangibleFixedAssetsName(), '11000');
        ContosoGLAccount.AddAccountForLocalization(DevelopmentExpenditureName(), '11100');
        ContosoGLAccount.AddAccountForLocalization(TenancySiteLeaseHoldandSimilarRightsName(), '11200');
        ContosoGLAccount.AddAccountForLocalization(GoodwillName(), '11300');
        ContosoGLAccount.AddAccountForLocalization(AdvancedPaymentsforIntangibleFixedAssetsName(), '11400');
        ContosoGLAccount.AddAccountForLocalization(TotalIntangibleFixedAssetsName(), '11999');
        ContosoGLAccount.AddAccountForLocalization(LandandBuildingsName(), '12100');
        ContosoGLAccount.AddAccountForLocalization(BuildingName(), '12110');
        ContosoGLAccount.AddAccountForLocalization(CostofImprovementstoLeasedPropertyName(), '12120');
        ContosoGLAccount.AddAccountForLocalization(LandName(), '12130');
        ContosoGLAccount.AddAccountForLocalization(TotalLandandbuildingName(), '12199');
        ContosoGLAccount.AddAccountForLocalization(MachineryandEquipmentName(), '12200');
        ContosoGLAccount.AddAccountForLocalization(EquipmentsandToolsName(), '12210');
        ContosoGLAccount.AddAccountForLocalization(ComputersName(), '12220');
        ContosoGLAccount.AddAccountForLocalization(CarsandOtherTransportEquipmentsName(), '12230');
        ContosoGLAccount.AddAccountForLocalization(LeasedAssetsName(), '12240');
        ContosoGLAccount.AddAccountForLocalization(TotalMachineryandEquipmentName(), '12299');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationName(), '12900');
        ContosoGLAccount.AddAccountForLocalization(TotalTangibleAssetsName(), '12999');
        ContosoGLAccount.AddAccountForLocalization(FinancialandFixedAssetsName(), '13000');
        ContosoGLAccount.AddAccountForLocalization(LongTermReceivablesName(), '13100');
        ContosoGLAccount.AddAccountForLocalization(ParticipationinGroupCompaniesName(), '13200');
        ContosoGLAccount.AddAccountForLocalization(LoanstoPartnersorRelatedPartiesName(), '13300');
        ContosoGLAccount.AddAccountForLocalization(DeferredTaxAssetsName(), '13400');
        ContosoGLAccount.AddAccountForLocalization(OtherLongTermReceivablesName(), '13500');
        ContosoGLAccount.AddAccountForLocalization(TotalFinancialandFixedAssetsName(), '13999');
        ContosoGLAccount.AddAccountForLocalization(InventoriesProductsandWorkinProgressName(), '14000');
        ContosoGLAccount.AddAccountForLocalization(SuppliesandConsumablesName(), '14100');
        ContosoGLAccount.AddAccountForLocalization(ProductsinProgressName(), '14120');
        ContosoGLAccount.AddAccountForLocalization(FinishedGoodsName(), '14130');
        ContosoGLAccount.AddAccountForLocalization(GoodsforResaleName(), '14140');
        ContosoGLAccount.AddAccountForLocalization(AdvancedPaymentsforGoodsandServicesName(), '14160');
        ContosoGLAccount.AddAccountForLocalization(OtherInventoryItemsName(), '14170');
        ContosoGLAccount.AddAccountForLocalization(WorkinProgressName(), '14200');
        ContosoGLAccount.AddAccountForLocalization(WorkinProgressFinishedGoodsName(), '14210');
        ContosoGLAccount.AddAccountForLocalization(WIPAccruedCostsName(), '14240');
        ContosoGLAccount.AddAccountForLocalization(WIPInvoicedSalesName(), '14250');
        ContosoGLAccount.AddAccountForLocalization(TotalWorkinProgressName(), '14299');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesName(), '15000');
        ContosoGLAccount.AddAccountForLocalization(AccountsReceivablesName(), '15100');
        ContosoGLAccount.AddAccountForLocalization(AccountReceivableDomesticName(), '15110');
        ContosoGLAccount.AddAccountForLocalization(AccountReceivableForeignName(), '15120');
        ContosoGLAccount.AddAccountForLocalization(ContractualReceivablesName(), '15130');
        ContosoGLAccount.AddAccountForLocalization(ConsignmentReceivablesName(), '15140');
        ContosoGLAccount.AddAccountForLocalization(CreditcardsandVouchersReceivablesName(), '15150');
        ContosoGLAccount.AddAccountForLocalization(TotalAccountReceivablesName(), '15199');
        ContosoGLAccount.AddAccountForLocalization(OtherCurrentReceivablesName(), '15900');
        ContosoGLAccount.AddAccountForLocalization(CurrentReceivablefromEmployeesName(), '15910');
        ContosoGLAccount.AddAccountForLocalization(AccruedincomenotYetInvoicedName(), '15920');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountsforTaxesandChargesName(), '15930');
        ContosoGLAccount.AddAccountForLocalization(TaxAssetsName(), '15940');
        ContosoGLAccount.AddAccountForLocalization(CurrentReceivablesFromGroupCompaniesName(), '15950');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherCurrentReceivablesName(), '15998');
        ContosoGLAccount.AddAccountForLocalization(TotalReceivablesName(), '15999');
        ContosoGLAccount.AddAccountForLocalization(PrepaidexpensesandAccruedIncomeName(), '16000');
        ContosoGLAccount.AddAccountForLocalization(PrepaidRentName(), '16100');
        ContosoGLAccount.AddAccountForLocalization(PrepaidInterestExpenseName(), '16200');
        ContosoGLAccount.AddAccountForLocalization(AccruedRentalIncomeName(), '16300');
        ContosoGLAccount.AddAccountForLocalization(AccruedInterestIncomeName(), '16400');
        ContosoGLAccount.AddAccountForLocalization(AssetsInFormOfPrepaidExpensesName(), '16500');
        ContosoGLAccount.AddAccountForLocalization(OtherPrepaidExpensesAndAccruedIncomeName(), '16600');
        ContosoGLAccount.AddAccountForLocalization(TotalPrepaidExpensesAndAccruedIncomeName(), '16999');
        ContosoGLAccount.AddAccountForLocalization(ShortTermInvestmentsName(), '17000');
        ContosoGLAccount.AddAccountForLocalization(ConvertibleDebtInstrumentsName(), '17200');
        ContosoGLAccount.AddAccountForLocalization(OtherShortTermInvestmentsName(), '17300');
        ContosoGLAccount.AddAccountForLocalization(WriteDownofShortTermInvestmentsName(), '17400');
        ContosoGLAccount.AddAccountForLocalization(TotalShortTermInvestmentsName(), '17999');
        ContosoGLAccount.AddAccountForLocalization(CashandBankName(), '18000');
        ContosoGLAccount.AddAccountForLocalization(BusinessAccountOperatingDomesticName(), '18200');
        ContosoGLAccount.AddAccountForLocalization(BusinessAccountOperatingForeignName(), '18300');
        ContosoGLAccount.AddAccountForLocalization(OtherBankAccountsName(), '18400');
        ContosoGLAccount.AddAccountForLocalization(CertificateofDepositName(), '18500');
        ContosoGLAccount.AddAccountForLocalization(TotalCashandBankName(), '18999');
        ContosoGLAccount.AddAccountForLocalization(LiabilityName(), '20000');
        ContosoGLAccount.AddAccountForLocalization(BondsandDebentureLoansName(), '21100');
        ContosoGLAccount.AddAccountForLocalization(ConvertiblesLoansName(), '21200');
        ContosoGLAccount.AddAccountForLocalization(OtherLongTermLiabilitiesName(), '21300');
        ContosoGLAccount.AddAccountForLocalization(BankOverdraftFacilitiesName(), '21400');
        ContosoGLAccount.AddAccountForLocalization(TotalLongTermLiabilitiesName(), '21999');
        ContosoGLAccount.AddAccountForLocalization(CurrentLiabilitiesName(), '22000');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableDomesticName(), '22100');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableForeignName(), '22200');
        ContosoGLAccount.AddAccountForLocalization(AdvancesfromcustomersName(), '22300');
        ContosoGLAccount.AddAccountForLocalization(ChangeinWorkinProgressName(), '22400');
        ContosoGLAccount.AddAccountForLocalization(BankOverdraftShortTermName(), '22500');
        ContosoGLAccount.AddAccountForLocalization(TotalCurrentLiabilitiesName(), '22999');
        ContosoGLAccount.AddAccountForLocalization(TaxLiabilitiesName(), '23000');
        ContosoGLAccount.AddAccountForLocalization(SalesTaxVATLiableName(), '23100');
        ContosoGLAccount.AddAccountForLocalization(TaxesLiableName(), '23200');
        ContosoGLAccount.AddAccountForLocalization(EstimatedIncomeTaxName(), '23300');
        ContosoGLAccount.AddAccountForLocalization(EstimatedPayrolltaxonPensionCostsName(), '23500');
        ContosoGLAccount.AddAccountForLocalization(TotalTaxLiabilitiesName(), '23999');
        ContosoGLAccount.AddAccountForLocalization(PayrollLiabilitiesName(), '24000');
        ContosoGLAccount.AddAccountForLocalization(EmployeesWithholdingTaxesName(), '24100');
        ContosoGLAccount.AddAccountForLocalization(StatutorySocialsecurityContributionsName(), '24200');
        ContosoGLAccount.AddAccountForLocalization(ContractualSocialSecurityContributionsName(), '24300');
        ContosoGLAccount.AddAccountForLocalization(AttachmentsofEarningName(), '24400');
        ContosoGLAccount.AddAccountForLocalization(HolidayPayfundName(), '24500');
        ContosoGLAccount.AddAccountForLocalization(OtherSalaryWageDeductionsName(), '24600');
        ContosoGLAccount.AddAccountForLocalization(TotalPayrollLiabilitiesName(), '24999');
        ContosoGLAccount.AddAccountForLocalization(OtherCurrentLiabilitiesName(), '25000');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountforFactoringCurrentPortionName(), '25100');
        ContosoGLAccount.AddAccountForLocalization(CurrentLiabilitiestoEmployeesName(), '25200');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountforThirdPartyName(), '25300');
        ContosoGLAccount.AddAccountForLocalization(CurrentLoansName(), '25400');
        ContosoGLAccount.AddAccountForLocalization(LiabilitiesGrantsReceivedName(), '25500');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherCurrentLiabilitiesName(), '25999');
        ContosoGLAccount.AddAccountForLocalization(AccruedExpensesandDeferredIncomeName(), '26000');
        ContosoGLAccount.AddAccountForLocalization(AccruedWagesSalariesName(), '26100');
        ContosoGLAccount.AddAccountForLocalization(AccruedHolidayPayName(), '26200');
        ContosoGLAccount.AddAccountForLocalization(AccruedPensionCostsName(), '26300');
        ContosoGLAccount.AddAccountForLocalization(AccruedInterestExpenseName(), '26400');
        ContosoGLAccount.AddAccountForLocalization(DeferredIncomeName(), '26500');
        ContosoGLAccount.AddAccountForLocalization(AccruedContractualCostsName(), '26600');
        ContosoGLAccount.AddAccountForLocalization(OtherAccruedExpensesandDeferredIncomeName(), '26700');
        ContosoGLAccount.AddAccountForLocalization(TotalAccruedExpensesandDeferredIncomeName(), '26999');
        ContosoGLAccount.AddAccountForLocalization(EquityName(), '30000');
        ContosoGLAccount.AddAccountForLocalization(EquityPartnerName(), '30100');
        ContosoGLAccount.AddAccountForLocalization(NetResultsName(), '30110');
        ContosoGLAccount.AddAccountForLocalization(RestrictedEquityName(), '30111');
        ContosoGLAccount.AddAccountForLocalization(ShareCapitalName(), '30200');
        ContosoGLAccount.AddAccountForLocalization(NonRestrictedEquityName(), '30210');
        ContosoGLAccount.AddAccountForLocalization(ProfitorLossFromthePreviousYearName(), '30300');
        ContosoGLAccount.AddAccountForLocalization(ResultsfortheFinancialYearName(), '30310');
        ContosoGLAccount.AddAccountForLocalization(DistributionstoShareholdersName(), '30320');
        ContosoGLAccount.AddAccountForLocalization(TotalEquityName(), '39999');

        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BalanceSheet(), CreateGLAccount.BalanceSheetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DiscountsandAllowances(), DiscountsandAllowancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleFixedAssets(), IntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DevelopmentExpenditure(), DevelopmentExpenditureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TenancySiteLeaseHoldandSimilarRights(), TenancySiteLeaseHoldandSimilarRightsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Goodwill(), GoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancedPaymentsforIntangibleFixedAssets(), AdvancedPaymentsforIntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalIntangibleFixedAssets(), TotalIntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, IntangibleFixedAssets() + '..' + TotalIntangibleFixedAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LandandBuildings(), LandandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Building(), BuildingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofImprovementstoLeasedProperty(), CostofImprovementstoLeasedPropertyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Land(), LandName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLandandbuilding(), TotalLandandbuildingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, LandandBuildings() + '..' + TotalLandandbuilding(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MachineryandEquipment(), MachineryandEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EquipmentsandTools(), EquipmentsandToolsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Computers(), ComputersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CarsandOtherTransportEquipments(), CarsandOtherTransportEquipmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LeasedAssets(), LeasedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMachineryandEquipment(), TotalMachineryandEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, MachineryandEquipment() + '..' + TotalMachineryandEquipment(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciation(), AccumulatedDepreciationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTangibleAssets(), TotalTangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.TangibleFixedAssets() + '..' + TotalTangibleAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialandFixedAssets(), FinancialandFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LongTermReceivables(), LongTermReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ParticipationinGroupCompanies(), ParticipationinGroupCompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LoanstoPartnersorRelatedParties(), LoanstoPartnersorRelatedPartiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredTaxAssets(), DeferredTaxAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLongTermReceivables(), OtherLongTermReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFinancialandFixedAssets(), TotalFinancialandFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, FinancialandFixedAssets() + '..' + TotalFinancialandFixedAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventoriesProductsandWorkinProgress(), InventoriesProductsandWorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SuppliesandConsumables(), SuppliesandConsumablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProductsinProgress(), ProductsinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsforResale(), GoodsforResaleName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancedPaymentsforGoodsandServices(), AdvancedPaymentsforGoodsandServicesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherInventoryItems(), OtherInventoryItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WorkinProgress(), WorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WorkinProgressFinishedGoods(), WorkinProgressFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WIPAccruedCosts(), WIPAccruedCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WIPInvoicedSales(), WIPInvoicedSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalWorkinProgress(), TotalWorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, WorkinProgress() + '..' + TotalWorkinProgress(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Receivables(), ReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsReceivables(), AccountsReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountReceivableDomestic(), AccountReceivableDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountReceivableForeign(), AccountReceivableForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ContractualReceivables(), ContractualReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsignmentReceivables(), ConsignmentReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreditcardsandVouchersReceivables(), CreditcardsandVouchersReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAccountReceivables(), TotalAccountReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccountsReceivables() + '..' + TotalAccountReceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCurrentReceivables(), OtherCurrentReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentReceivablefromEmployees(), CurrentReceivablefromEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedincomenotYetInvoiced(), AccruedincomenotYetInvoicedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountsforTaxesandCharges(), ClearingAccountsforTaxesandChargesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxAssets(), TaxAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentReceivablesFromGroupCompanies(), CurrentReceivablesFromGroupCompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherCurrentReceivables(), TotalOtherCurrentReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherCurrentReceivables() + '..' + TotalOtherCurrentReceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalReceivables(), TotalReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Receivables() + '..' + TotalReceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidexpensesandAccruedIncome(), PrepaidexpensesandAccruedIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidRent(), PrepaidRentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidInterestExpense(), PrepaidInterestExpenseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedRentalIncome(), AccruedRentalIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedInterestIncome(), AccruedInterestIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssetsInFormOfPrepaidExpenses(), AssetsInFormOfPrepaidExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPrepaidExpensesAndAccruedIncome(), OtherPrepaidExpensesAndAccruedIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPrepaidExpensesAndAccruedIncome(), TotalPrepaidExpensesAndAccruedIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, PrepaidexpensesandAccruedIncome() + '..' + TotalPrepaidExpensesAndAccruedIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ShortTermInvestments(), ShortTermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ConvertibleDebtInstruments(), ConvertibleDebtInstrumentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherShortTermInvestments(), OtherShortTermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WriteDownofShortTermInvestments(), WriteDownofShortTermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalShortTermInvestments(), TotalShortTermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, ShortTermInvestments() + '..' + TotalShortTermInvestments(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CashandBank(), CashandBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessAccountOperatingDomestic(), BusinessAccountOperatingDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessAccountOperatingForeign(), BusinessAccountOperatingForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherBankAccounts(), OtherBankAccountsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CertificateofDeposit(), CertificateofDepositName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCashandBank(), TotalCashandBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CashandBank() + '..' + TotalCashandBank(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Liability(), LiabilityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BondsandDebentureLoans(), BondsandDebentureLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConvertiblesLoans(), ConvertiblesLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLongTermLiabilities(), OtherLongTermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankOverdraftFacilities(), BankOverdraftFacilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLongTermLiabilities(), TotalLongTermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LongtermLiabilities() + '..' + TotalLongTermLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLiabilities(), CurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayableDomestic(), AccountsPayableDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayableForeign(), AccountsPayableForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Advancesfromcustomers(), AdvancesfromcustomersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ChangeinWorkinProgress(), ChangeinWorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankOverdraftShortTerm(), BankOverdraftShortTermName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilities(), CreateGLAccount.OtherLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCurrentLiabilities(), TotalCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CurrentLiabilities() + '..' + TotalCurrentLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TaxLiabilities(), TaxLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesTaxVATLiable(), SalesTaxVATLiableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesLiable(), TaxesLiableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedIncomeTax(), EstimatedIncomeTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedPayrolltaxonPensionCosts(), EstimatedPayrolltaxonPensionCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTaxLiabilities(), TotalTaxLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, TaxLiabilities() + '..' + TotalTaxLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PayrollLiabilities(), PayrollLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EmployeesWithholdingTaxes(), EmployeesWithholdingTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StatutorySocialsecurityContributions(), StatutorySocialsecurityContributionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ContractualSocialSecurityContributions(), ContractualSocialSecurityContributionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AttachmentsofEarning(), AttachmentsofEarningName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HolidayPayfund(), HolidayPayfundName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherSalaryWageDeductions(), OtherSalaryWageDeductionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPayrollLiabilities(), TotalPayrollLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, PayrollLiabilities() + '..' + TotalPayrollLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCurrentLiabilities(), OtherCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountforFactoringCurrentPortion(), ClearingAccountforFactoringCurrentPortionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLiabilitiestoEmployees(), CurrentLiabilitiestoEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountforThirdParty(), ClearingAccountforThirdPartyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLoans(), CurrentLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LiabilitiesGrantsReceived(), LiabilitiesGrantsReceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherCurrentLiabilities(), TotalOtherCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherCurrentLiabilities() + '..' + TotalOtherCurrentLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedExpensesandDeferredIncome(), AccruedExpensesandDeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedWagesSalaries(), AccruedWagesSalariesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedHolidayPay(), AccruedHolidayPayName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedPensionCosts(), AccruedPensionCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedInterestExpense(), AccruedInterestExpenseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredIncome(), DeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedContractualCosts(), AccruedContractualCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherAccruedExpensesandDeferredIncome(), OtherAccruedExpensesandDeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAccruedExpensesandDeferredIncome(), TotalAccruedExpensesandDeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccruedExpensesandDeferredIncome() + '..' + TotalAccruedExpensesandDeferredIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Equity(), EquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EquityPartner(), EquityPartnerName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NetResults(), NetResultsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RestrictedEquity(), RestrictedEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ShareCapital(), ShareCapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NonRestrictedEquity(), NonRestrictedEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProfitorLossFromthePreviousYear(), ProfitorLossFromthePreviousYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ResultsfortheFinancialYear(), ResultsfortheFinancialYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DistributionstoShareholders(), DistributionstoShareholdersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalEquity(), TotalEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, Equity() + '..' + TotalEquity(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncomeStatement(), CreateGLAccount.IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Income(), IncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofGoods(), SalesofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofFinishedGoods(), SaleofFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofRawMaterials(), SaleofRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ResaleofGoods(), ResaleofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesofGoods(), TotalSalesofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesofGoods() + '..' + TotalSalesofGoods(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofResources(), SaleofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofSubcontracting(), SaleofSubcontractingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesofResources(), TotalSalesofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesofResources() + '..' + TotalSalesofResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdditionalRevenue(), AdditionalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromSecurities(), IncomeFromSecuritiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementFeeRevenue(), ManagementFeeRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrencyGains(), CurrencyGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherIncidentalRevenue(), OtherIncidentalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdditionalRevenue(), TotalAdditionalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, AdditionalRevenue() + '..' + TotalAdditionalRevenue(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobsandServices(), JobsandServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesApplied(), JobSalesAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofServiceContracts(), SalesofServiceContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofServiceWork(), SalesofServiceWorkName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalJobsandServices(), TotalJobsandServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, JobsandServices() + '..' + TotalJobsandServices(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueReductions(), RevenueReductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesDiscounts(), SalesDiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesInvoiceRounding(), SalesInvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentToleranceandAllowances(), PaymentToleranceandAllowancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesReturns(), SalesReturnsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRevenueReductions(), TotalRevenueReductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, RevenueReductions() + '..' + TotalRevenueReductions(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalIncome(), TotalIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, Income() + '..' + TotalIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofGoodsSold(), CostofGoodsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofGoods(), CostofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofMaterials(), CostofMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofMaterialsProjects(), CostofMaterialsProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofGoods(), TotalCostofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofGoods() + '..' + TotalCostofGoods(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofResourcesandServices(), CostofResourcesandServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofLabor(), CostofLaborName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofLaborProjects(), CostofLaborProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofLaborWarrantyContract(), CostofLaborWarrantyContractName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofResources(), TotalCostofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofResourcesandServices() + '..' + TotalCostofResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SubcontractedWork(), SubcontractedWorkName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofVariances(), CostofVariancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofGoodsSold(), TotalCostofGoodsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofGoodsSold() + '..' + TotalCostofGoodsSold(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Expenses(), ExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FacilityExpenses(), FacilityExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentalFacilities(), RentalFacilitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentLeases(), RentLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityforRental(), ElectricityforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HeatingforRental(), HeatingforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WaterandSewerageforRental(), WaterandSewerageforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CleaningandWasteforRental(), CleaningandWasteforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RepairsandMaintenanceforRental(), RepairsandMaintenanceforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesRental(), InsurancesRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherRentalExpenses(), OtherRentalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRentalFacilities(), TotalRentalFacilitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, RentalFacilities() + '..' + TotalRentalFacilities(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PropertyExpenses(), PropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SiteFeesLeases(), SiteFeesLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityforProperty(), ElectricityforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HeatingforProperty(), HeatingforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WaterandSewerageforProperty(), WaterandSewerageforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CleaningandWasteforProperty(), CleaningandWasteforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RepairsandMaintenanceforProperty(), RepairsandMaintenanceforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesProperty(), InsurancesPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPropertyExpenses(), OtherPropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPropertyExpenses(), TotalPropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, PropertyExpenses() + '..' + TotalPropertyExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFacilityExpenses(), TotalFacilityExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FacilityExpenses() + '..' + TotalFacilityExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FixedAssetsLeases(), FixedAssetsLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HireofMachinery(), HireofMachineryName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HireofComputers(), HireofComputersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HireofOtherFixedAssets(), HireofOtherFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFixedAssetLeases(), TotalFixedAssetLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FixedAssetsLeases() + '..' + TotalFixedAssetLeases(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LogisticsExpenses(), LogisticsExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PassengerCarCosts(), PassengerCarCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TruckCosts(), TruckCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherVehicleExpenses(), OtherVehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalVehicleExpenses(), TotalVehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.VehicleExpenses() + '..' + TotalVehicleExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FreightCosts(), FreightCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FreightFeesForGoods(), FreightFeesForGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CustomsandForwarding(), CustomsandForwardingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FreightFeesProjects(), FreightFeesProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFreightCosts(), TotalFreightCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FreightCosts() + '..' + TotalFreightCosts(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TravelExpenses(), TravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Tickets(), TicketsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RentalVehicles(), RentalVehiclesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BoardandLodging(), BoardandLodgingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherTravelExpenses(), OtherTravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTravelExpenses(), TotalTravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, TravelExpenses() + '..' + TotalTravelExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLogisticsExpenses(), TotalLogisticsExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, LogisticsExpenses() + '..' + TotalLogisticsExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MarketingandSales(), MarketingandSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.Advertising(), CreateGlAccount.AdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvertisementDevelopment(), AdvertisementDevelopmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OutdoorandTransportationAds(), OutdoorandTransportationAdsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdMatterandDirectMailings(), AdMatterandDirectMailingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConferenceExhibitionSponsorship(), ConferenceExhibitionSponsorshipName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SamplesContestsGifts(), SamplesContestsGiftsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FilmTVRadioInternetAds(), FilmTVRadioInternetAdsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PRandAgencyFees(), PRandAgencyFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherAdvertisingFees(), OtherAdvertisingFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdvertising(), TotalAdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Advertising() + '..' + TotalAdvertising(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherMarketingExpenses(), OtherMarketingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CatalogsPriceLists(), CatalogsPriceListsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradePublications(), TradePublicationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherMarketingExpenses(), TotalOtherMarketingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherMarketingExpenses() + '..' + TotalOtherMarketingExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesExpenses(), SalesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreditCardCharges(), CreditCardChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessEntertainingDeductible(), BusinessEntertainingDeductibleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessEntertainingNonDeductible(), BusinessEntertainingNonDeductibleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesExpenses(), TotalSalesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesExpenses() + '..' + TotalSalesExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMarketingandSales(), TotalMarketingandSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, MarketingandSales() + '..' + TotalMarketingandSales(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeExpenses(), OfficeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PhoneServices(), PhoneServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DataServices(), DataServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostalFees(), PostalFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsumableExpensibleHardware(), ConsumableExpensibleHardwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SoftwareandSubscriptionFees(), SoftwareandSubscriptionFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOfficeExpenses(), TotalOfficeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OfficeExpenses() + '..' + TotalOfficeExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesandRisks(), InsurancesandRisksName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CorporateInsurance(), CorporateInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DamagesPaid(), DamagesPaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BadDebtLosses(), BadDebtLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SecurityServices(), SecurityServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherRiskExpenses(), OtherRiskExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInsurancesandRisks(), TotalInsurancesandRisksName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, InsurancesandRisks() + '..' + TotalInsurancesandRisks(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementandAdmin(), ManagementandAdminName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Management(), ManagementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RemunerationtoDirectors(), RemunerationtoDirectorsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementFees(), ManagementFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnnualInterrimReports(), AnnualInterrimReportsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnnualGeneralMeeting(), AnnualGeneralMeetingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AuditandAuditServices(), AuditandAuditServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxAdvisoryServices(), TaxAdvisoryServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalManagementFees(), TotalManagementFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Management() + '..' + TotalManagementFees(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalManagementandAdmin(), TotalManagementandAdminName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ManagementandAdmin() + '..' + TotalManagementandAdmin(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankingandInterest(), BankingandInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankingFees(), BankingFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.InterestExpenses(), CreateGlAccount.InterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayableInvoiceRounding(), PayableInvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBankingandInterest(), TotalBankingandInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, BankingandInterest() + '..' + TotalBankingandInterest(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ExternalServicesExpenses(), ExternalServicesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ExternalServices(), ExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountingServices(), AccountingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ITServices(), ITServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MediaServices(), MediaServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsultingServices(), ConsultingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LegalFeesandAttorneyServices(), LegalFeesandAttorneyServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherExternalServices(), OtherExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalExternalServices(), TotalExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ExternalServices() + '..' + TotalExternalServices(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherExternalExpenses(), OtherExternalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LicenseFeesRoyalties(), LicenseFeesRoyaltiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TrademarksPatents(), TrademarksPatentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssociationFees(), AssociationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscExternalExpenses(), MiscExternalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseDiscounts(), PurchaseDiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherExternalExpenses(), TotalOtherExternalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherExternalExpenses() + '..' + TotalOtherExternalExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalExternalServicesExpenses(), TotalExternalServicesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ExternalServicesExpenses() + '..' + TotalExternalServicesExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Personnel(), PersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WagesandSalaries(), WagesandSalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HourlyWages(), HourlyWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OvertimeWages(), OvertimeWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Bonuses(), BonusesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CommissionsPaid(), CommissionsPaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PTOAccrued(), PTOAccruedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalWagesandSalaries(), TotalWagesandSalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, WagesandSalaries() + '..' + TotalWagesandSalaries(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BenefitsPension(), BenefitsPensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Benefits(), BenefitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TrainingCosts(), TrainingCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HealthCareContributions(), HealthCareContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EntertainmentofPersonnel(), EntertainmentofPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.Allowances(), CreateGlAccount.AllowancesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MandatoryClothingExpenses(), MandatoryClothingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCashRemunerationBenefits(), OtherCashRemunerationBenefitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBenefits(), TotalBenefitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Benefits() + '..' + TotalBenefits(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Pension(), PensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PensionFeesandRecurringCosts(), PensionFeesandRecurringCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EmployerContributions(), EmployerContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPension(), TotalPensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Pension() + '..' + TotalPension(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBenefitsPension(), TotalBenefitsPensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, BenefitsPension() + '..' + TotalBenefitsPension(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesPersonnel(), InsurancesPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HealthInsurance(), HealthInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DentalInsurance(), DentalInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WorkersCompensation(), WorkersCompensationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LifeInsurance(), LifeInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInsurancesPersonnel(), TotalInsurancesPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, InsurancesPersonnel() + '..' + TotalInsurancesPersonnel(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PersonnelTaxes(), PersonnelTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FederalPersonnelTaxes(), FederalPersonnelTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FederalWithholdingExpense(), FederalWithholdingExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FICAExpense(), FICAExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FUTAExpense(), FUTAExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MedicareExpense(), MedicareExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherFederalExpense(), OtherFederalExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFederalPersonnelTaxes(), TotalFederalPersonnelTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FederalPersonnelTaxes() + '..' + TotalFederalPersonnelTaxes(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StatePersonnelTaxes(), StatePersonnelTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StateWithholdingExpense(), StateWithholdingExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SUTAExpense(), SUTAExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalStatePersonnelTaxes(), TotalStatePersonnelTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, StatePersonnelTaxes() + '..' + TotalStatePersonnelTaxes(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPersonnelTaxes(), TotalPersonnelTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, PersonnelTaxes() + '..' + TotalPersonnelTaxes(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPersonnel(), TotalPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Personnel() + '..' + TotalPersonnel(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation(), DepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationLandandProperty(), DepreciationLandandPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationFixedAssets(), DepreciationFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalDepreciation(), TotalDepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Depreciation() + '..' + TotalDepreciation(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MiscExpenses(), MiscExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrencyLosses(), CurrencyLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMiscExpenses(), TotalMiscExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, MiscExpenses() + '..' + TotalMiscExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalExpenses(), TotalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Expenses() + '..' + TotalExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InterestIncome(), InterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.NetIncome(), CreateGlAccount.NetIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Total, '', '', 1, CreateGLAccount.INCOMESTATEMENT() + '..' + '49999' + '|' + '50000' + '..' + '59999' + '|' + '60000' + '..' + CreateGLAccount.NETINCOME(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.OfficeSupplies(), CreateGlAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.VehicleExpenses(), CreateGlAccount.VehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.Salaries(), CreateGlAccount.SalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.FinishedGoods(), CreateGlAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.WIPJobSales(), CreateGlAccount.WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.WIPJobCosts(), CreateGlAccount.WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.RawMaterials(), CreateGlAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGlAccount.JobSales(), CreateGlAccount.JobSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
    end;

    procedure DiscountsandAllowancesName(): Text[100]
    begin
        exit(DiscountsandAllowancesLbl);
    end;

    procedure DiscountsandAllowances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountsandAllowancesName()));
    end;

    procedure SalesofServiceWorkName(): Text[100]
    begin
        exit(SalesofServiceWorkLbl);
    end;

    procedure SalesofServiceWork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofServiceWorkName()));
    end;

    procedure ResaleofGoodsName(): Text[100]
    begin
        exit(ResaleofGoodsLbl);
    end;

    procedure ResaleofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResaleofGoodsName()));
    end;

    procedure InterestIncomeName(): Text[100]
    begin
        exit(InterestIncomeLbl);
    end;

    procedure InterestIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestIncomeName()));
    end;

    procedure CostofMaterialsName(): Text[100]
    begin
        exit(CostofMaterialsLbl);
    end;

    procedure CostofMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofMaterialsName()));
    end;

    procedure DepreciationFixedAssetsName(): Text[100]
    begin
        exit(DepreciationFixedAssetsLbl);
    end;

    procedure DepreciationFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationFixedAssetsName()));
    end;

    procedure DepreciationLandandPropertyName(): Text[100]
    begin
        exit(DepreciationLandandPropertyLbl);
    end;

    procedure DepreciationLandandProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationLandandPropertyName()));
    end;

    procedure TaxesLiableName(): Text[100]
    begin
        exit(TaxesLiableLbl);
    end;

    procedure TaxesLiable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesLiableName()));
    end;

    procedure Income(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeName()));
    end;

    procedure IncomeName(): Text[100]
    begin
        exit(IncomeLbl);
    end;

    procedure SalesofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo((SalesofGoodsName())));
    end;

    procedure SalesofGoodsName(): Text[100]
    begin
        exit(SalesofGoodsLbl);
    end;

    procedure SaleofFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofFinishedGoodsName()));
    end;

    procedure SaleofFinishedGoodsName(): Text[100]
    begin
        exit(SaleofFinishedGoodsLbl);
    end;

    procedure SaleofRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofRawMaterialsName()));
    end;

    procedure SaleofRawMaterialsName(): Text[100]
    begin
        exit(SaleofRawMaterialsLbl);
    end;

    procedure TotalSalesofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesofGoodsName()));
    end;

    procedure TotalSalesofGoodsName(): Text[100]
    begin
        exit(TotalSalesofGoodsTok);
    end;

    procedure SaleofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofResourcesName()));
    end;

    procedure SaleofResourcesName(): Text[100]
    begin
        exit(SaleofResourcesTok);
    end;

    procedure SaleofSubcontracting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofSubcontractingName()));
    end;

    procedure SaleofSubcontractingName(): Text[100]
    begin
        exit(SaleofSubcontractingTok);
    end;

    procedure TotalSalesofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesofResourcesName()));
    end;

    procedure TotalSalesofResourcesName(): Text[100]
    begin
        exit(TotalSalesofResourcesTok);
    end;

    procedure AdditionalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionalRevenueName()));
    end;

    procedure AdditionalRevenueName(): Text[100]
    begin
        exit(AdditionalRevenueTok);
    end;

    procedure IncomeFromSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromSecuritiesName()));
    end;

    procedure IncomeFromSecuritiesName(): Text[100]
    begin
        exit(IncomeFromSecuritiesTok);
    end;

    procedure ManagementFeeRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementFeeRevenueName()));
    end;

    procedure ManagementFeeRevenueName(): Text[100]
    begin
        exit(ManagementFeeRevenueTok);
    end;

    procedure CurrencyGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrencyGainsName()));
    end;

    procedure CurrencyGainsName(): Text[100]
    begin
        exit(CurrencyGainsTok);
    end;

    procedure OtherIncidentalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherIncidentalRevenueName()));
    end;

    procedure OtherIncidentalRevenueName(): Text[100]
    begin
        exit(OtherIncidentalRevenueTok);
    end;

    procedure TotalAdditionalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdditionalRevenueName()));
    end;

    procedure TotalAdditionalRevenueName(): Text[100]
    begin
        exit(TotalAdditionalRevenueTok);
    end;

    procedure JobsandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobsandServicesName()));
    end;

    procedure JobsandServicesName(): Text[100]
    begin
        exit(JobsandServicesTok);
    end;

    procedure JobSalesApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedName()));
    end;

    procedure JobSalesAppliedName(): Text[100]
    begin
        exit(JobSalesAppliedTok);
    end;

    procedure SalesofServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofServiceContractsName()));
    end;

    procedure SalesofServiceContractsName(): Text[100]
    begin
        exit(SalesofServiceContractsTok);
    end;

    procedure TotalJobsandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalJobsandServicesName()));
    end;

    procedure TotalJobsandServicesName(): Text[100]
    begin
        exit(TotalJobsandServicesTok);
    end;

    procedure RevenueReductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueReductionsName()));
    end;

    procedure RevenueReductionsName(): Text[100]
    begin
        exit(RevenueReductionsTok);
    end;

    procedure SalesDiscounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesDiscountsName()));
    end;

    procedure SalesDiscountsName(): Text[100]
    begin
        exit(DiscountsandAllowancesTok);
    end;

    procedure SalesInvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesInvoiceRoundingName()));
    end;

    procedure SalesInvoiceRoundingName(): Text[100]
    begin
        exit(InvoiceRoundingTok);
    end;

    procedure PaymentToleranceandAllowances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentToleranceandAllowancesName()));
    end;

    procedure PaymentToleranceandAllowancesName(): Text[100]
    begin
        exit(PaymentToleranceTok);
    end;

    procedure SalesReturns(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesReturnsName()));
    end;

    procedure SalesReturnsName(): Text[100]
    begin
        exit(SalesReturnsTok);
    end;

    procedure TotalRevenueReductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRevenueReductionsName()));
    end;

    procedure TotalRevenueReductionsName(): Text[100]
    begin
        exit(TotalRevenueReductionsTok);
    end;

    procedure TotalIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalIncomeName()));
    end;

    procedure TotalIncomeName(): Text[100]
    begin
        exit(TotalIncomeTok);
    end;

    procedure CostofGoodsSold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofGoodsSoldName()));
    end;

    procedure CostofGoodsSoldName(): Text[100]
    begin
        exit(CostofGoodsSoldTok);
    end;

    procedure CostofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofGoodsName()));
    end;

    procedure CostofGoodsName(): Text[100]
    begin
        exit(CostofGoodsTok);
    end;

    procedure CostofMaterialsProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofMaterialsProjectsName()));
    end;

    procedure CostofMaterialsProjectsName(): Text[100]
    begin
        exit(CostofMaterialsProjectsTok);
    end;

    procedure TotalCostofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofGoodsName()));
    end;

    procedure TotalCostofGoodsName(): Text[100]
    begin
        exit(TotalCostofGoodsTok);
    end;

    procedure CostofResourcesandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofResourcesandServicesName()));
    end;

    procedure CostofResourcesandServicesName(): Text[100]
    begin
        exit(CostofResourcesandServicesTok);
    end;

    procedure CostofLabor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofLaborName()));
    end;

    procedure CostofLaborName(): Text[100]
    begin
        exit(CostofLaborTok);
    end;

    procedure CostofLaborProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofLaborProjectsName()));
    end;

    procedure CostofLaborProjectsName(): Text[100]
    begin
        exit(CostofLaborProjectsTok);
    end;

    procedure CostofLaborWarrantyContract(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofLaborWarrantyContractName()));
    end;

    procedure CostofLaborWarrantyContractName(): Text[100]
    begin
        exit(CostofLaborWarrantyContractTok);
    end;

    procedure TotalCostofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofResourcesName()));
    end;

    procedure TotalCostofResourcesName(): Text[100]
    begin
        exit(TotalCostofResourcesTok);
    end;

    procedure SubcontractedWork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedWorkName()));
    end;

    procedure SubcontractedWorkName(): Text[100]
    begin
        exit(SubcontractedWorkTok);
    end;

    procedure CostofVariances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofVariancesName()));
    end;

    procedure CostofVariancesName(): Text[100]
    begin
        exit(CostofVariancesTok);
    end;

    procedure TotalCostofGoodsSold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofGoodsSoldName()));
    end;

    procedure TotalCostofGoodsSoldName(): Text[100]
    begin
        exit(TotalCostofGoodsSoldTok);
    end;

    procedure Expenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpensesName()));
    end;

    procedure ExpensesName(): Text[100]
    begin
        exit(ExpenseTok);
    end;

    procedure FacilityExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FacilityExpensesName()));
    end;

    procedure FacilityExpensesName(): Text[100]
    begin
        exit(FacilityExpensesTok);
    end;

    procedure RentalFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalFacilitiesName()));
    end;

    procedure RentalFacilitiesName(): Text[100]
    begin
        exit(RentalFacilitiesTok);
    end;

    procedure RentLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentLeasesName()));
    end;

    procedure RentLeasesName(): Text[100]
    begin
        exit(RentLeasesTok);
    end;

    procedure ElectricityforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityforRentalName()));
    end;

    procedure ElectricityforRentalName(): Text[100]
    begin
        exit(ElectricityforRentalTok);
    end;

    procedure HeatingforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HeatingforRentalName()));
    end;

    procedure HeatingforRentalName(): Text[100]
    begin
        exit(HeatingforRentalTok);
    end;

    procedure WaterandSewerageforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterandSewerageforRentalName()));
    end;

    procedure WaterandSewerageforRentalName(): Text[100]
    begin
        exit(WaterandSewerageforRentalTok);
    end;

    procedure CleaningandWasteforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningandWasteforRentalName()));
    end;

    procedure CleaningandWasteforRentalName(): Text[100]
    begin
        exit(CleaningandWasteforRentalTok);
    end;

    procedure RepairsandMaintenanceforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsandMaintenanceforRentalName()));
    end;

    procedure RepairsandMaintenanceforRentalName(): Text[100]
    begin
        exit(RepairsandMaintenanceforRentalTok);
    end;

    procedure InsurancesRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesRentalName()));
    end;

    procedure InsurancesRentalName(): Text[100]
    begin
        exit(InsurancesRentalTok);
    end;

    procedure OtherRentalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherRentalExpensesName()));
    end;

    procedure OtherRentalExpensesName(): Text[100]
    begin
        exit(OtherRentalExpensesTok);
    end;

    procedure TotalRentalFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRentalFacilitiesName()));
    end;

    procedure TotalRentalFacilitiesName(): Text[100]
    begin
        exit(TotalRentalFacilitiesTok);
    end;

    procedure PropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PropertyExpensesName()));
    end;

    procedure PropertyExpensesName(): Text[100]
    begin
        exit(PropertyExpensesTok);
    end;

    procedure SiteFeesLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SiteFeesLeasesName()));
    end;

    procedure SiteFeesLeasesName(): Text[100]
    begin
        exit(SiteFeesLeasesTok);
    end;

    procedure ElectricityforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityforPropertyName()));
    end;

    procedure ElectricityforPropertyName(): Text[100]
    begin
        exit(ElectricityforPropertyTok);
    end;

    procedure HeatingforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HeatingforPropertyName()));
    end;

    procedure HeatingforPropertyName(): Text[100]
    begin
        exit(HeatingforPropertyTok);
    end;

    procedure WaterandSewerageforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterandSewerageforPropertyName()));
    end;

    procedure WaterandSewerageforPropertyName(): Text[100]
    begin
        exit(WaterandSewerageforPropertyTok);
    end;

    procedure CleaningandWasteforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningandWasteforPropertyName()));
    end;

    procedure CleaningandWasteforPropertyName(): Text[100]
    begin
        exit(CleaningandWasteforPropertyTok);
    end;

    procedure RepairsandMaintenanceforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsandMaintenanceforPropertyName()));
    end;

    procedure RepairsandMaintenanceforPropertyName(): Text[100]
    begin
        exit(RepairsandMaintenanceforPropertyTok);
    end;

    procedure InsurancesProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesPropertyName()));
    end;

    procedure InsurancesPropertyName(): Text[100]
    begin
        exit(InsurancesPropertyTok);
    end;

    procedure OtherPropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherPropertyExpensesName()));
    end;

    procedure OtherPropertyExpensesName(): Text[100]
    begin
        exit(OtherPropertyExpensesTok);
    end;

    procedure TotalPropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPropertyExpensesName()));
    end;

    procedure TotalPropertyExpensesName(): Text[100]
    begin
        exit(TotalPropertyExpensesTok);
    end;

    procedure TotalFacilityExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFacilityExpensesName()));
    end;

    procedure TotalFacilityExpensesName(): Text[100]
    begin
        exit(TotalFacilityExpensesTok);
    end;

    procedure FixedAssetsLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetsLeasesName()));
    end;

    procedure FixedAssetsLeasesName(): Text[100]
    begin
        exit(FixedAssetsLeasesTok);
    end;

    procedure HireofMachinery(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireofMachineryName()));
    end;

    procedure HireofMachineryName(): Text[100]
    begin
        exit(HireofMachineryTok);
    end;

    procedure HireofComputers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireofComputersName()));
    end;

    procedure HireofComputersName(): Text[100]
    begin
        exit(HireofComputersTok);
    end;

    procedure HireofOtherFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireofOtherFixedAssetsName()));
    end;

    procedure HireofOtherFixedAssetsName(): Text[100]
    begin
        exit(HireofOtherFixedAssetsTok);
    end;

    procedure TotalFixedAssetLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFixedAssetLeasesName()));
    end;

    procedure TotalFixedAssetLeasesName(): Text[100]
    begin
        exit(TotalFixedAssetLeasesTok);
    end;

    procedure LogisticsExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LogisticsExpensesName()));
    end;

    procedure LogisticsExpensesName(): Text[100]
    begin
        exit(LogisticsExpensesTok);
    end;

    procedure PassengerCarCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PassengerCarCostsName()));
    end;

    procedure PassengerCarCostsName(): Text[100]
    begin
        exit(PassengerCarCostsTok);
    end;

    procedure TruckCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TruckCostsName()));
    end;

    procedure TruckCostsName(): Text[100]
    begin
        exit(TruckCostsTok);
    end;

    procedure OtherVehicleExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherVehicleExpensesName()));
    end;

    procedure OtherVehicleExpensesName(): Text[100]
    begin
        exit(OtherVehicleExpensesTok);
    end;

    procedure TotalVehicleExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalVehicleExpensesName()));
    end;

    procedure TotalVehicleExpensesName(): Text[100]
    begin
        exit(TotalVehicleExpensesTok);
    end;

    procedure FreightCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightCostsName()));
    end;

    procedure FreightCostsName(): Text[100]
    begin
        exit(FreightCostsTok);
    end;

    procedure FreightFeesForGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightFeesForGoodsName()));
    end;

    procedure FreightFeesForGoodsName(): Text[100]
    begin
        exit(FreightFeesForGoodsTok);
    end;

    procedure CustomsandForwarding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomsandForwardingName()));
    end;

    procedure CustomsandForwardingName(): Text[100]
    begin
        exit(CustomsandForwardingTok);
    end;

    procedure FreightFeesProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightFeesProjectsName()));
    end;

    procedure FreightFeesProjectsName(): Text[100]
    begin
        exit(FreightFeesProjectsTok);
    end;

    procedure TotalFreightCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFreightCostsName()));
    end;

    procedure TotalFreightCostsName(): Text[100]
    begin
        exit(TotalFreightCostsTok);
    end;

    procedure TravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelExpensesName()));
    end;

    procedure TravelExpensesName(): Text[100]
    begin
        exit(TravelExpensesTok);
    end;

    procedure Tickets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TicketsName()));
    end;

    procedure TicketsName(): Text[100]
    begin
        exit(TicketsTok);
    end;

    procedure RentalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalVehiclesName()));
    end;

    procedure RentalVehiclesName(): Text[100]
    begin
        exit(RentalVehiclesTok);
    end;

    procedure BoardandLodging(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BoardandLodgingName()));
    end;

    procedure BoardandLodgingName(): Text[100]
    begin
        exit(BoardandLodgingTok);
    end;

    procedure OtherTravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherTravelExpensesName()));
    end;

    procedure OtherTravelExpensesName(): Text[100]
    begin
        exit(OtherTravelExpensesTok);
    end;

    procedure TotalTravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTravelExpensesName()));
    end;

    procedure TotalTravelExpensesName(): Text[100]
    begin
        exit(TotalTravelExpensesTok);
    end;

    procedure TotalLogisticsExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLogisticsExpensesName()));
    end;

    procedure TotalLogisticsExpensesName(): Text[100]
    begin
        exit(TotalLogisticsExpensesTok);
    end;

    procedure MarketingandSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MarketingandSalesName()));
    end;

    procedure MarketingandSalesName(): Text[100]
    begin
        exit(MarketingandSalesTok);
    end;

    procedure AdvertisementDevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertisementDevelopmentName()));
    end;

    procedure AdvertisementDevelopmentName(): Text[100]
    begin
        exit(AdvertisementDevelopmentTok);
    end;

    procedure OutdoorandTransportationAds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutdoorandTransportationAdsName()));
    end;

    procedure OutdoorandTransportationAdsName(): Text[100]
    begin
        exit(OutdoorandTransportationAdsTok);
    end;

    procedure AdMatterandDirectMailings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdMatterandDirectMailingsName()));
    end;

    procedure AdMatterandDirectMailingsName(): Text[100]
    begin
        exit(AdMatterandDirectMailingsTok);
    end;

    procedure ConferenceExhibitionSponsorship(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConferenceExhibitionSponsorshipName()));
    end;

    procedure ConferenceExhibitionSponsorshipName(): Text[100]
    begin
        exit(ConferenceExhibitionSponsorshipTok);
    end;

    procedure SamplesContestsGifts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SamplesContestsGiftsName()));
    end;

    procedure SamplesContestsGiftsName(): Text[100]
    begin
        exit(SamplesContestsGiftsTok);
    end;

    procedure FilmTVRadioInternetAds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FilmTVRadioInternetAdsName()));
    end;

    procedure FilmTVRadioInternetAdsName(): Text[100]
    begin
        exit(FilmTVRadioInternetAdsTok);
    end;

    procedure PRandAgencyFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PRandAgencyFeesName()));
    end;

    procedure PRandAgencyFeesName(): Text[100]
    begin
        exit(PRandAgencyFeesTok);
    end;

    procedure OtherAdvertisingFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherAdvertisingFeesName()));
    end;

    procedure OtherAdvertisingFeesName(): Text[100]
    begin
        exit(OtherAdvertisingFeesTok);
    end;

    procedure TotalAdvertising(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdvertisingName()));
    end;

    procedure TotalAdvertisingName(): Text[100]
    begin
        exit(TotalAdvertisingTok);
    end;

    procedure OtherMarketingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherMarketingExpensesName()));
    end;

    procedure OtherMarketingExpensesName(): Text[100]
    begin
        exit(OtherMarketingExpensesTok);
    end;

    procedure CatalogsPriceLists(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CatalogsPriceListsName()));
    end;

    procedure CatalogsPriceListsName(): Text[100]
    begin
        exit(CatalogsPriceListsTok);
    end;

    procedure TradePublications(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradePublicationsName()));
    end;

    procedure TradePublicationsName(): Text[100]
    begin
        exit(TradePublicationsTok);
    end;

    procedure TotalOtherMarketingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherMarketingExpensesName()));
    end;

    procedure TotalOtherMarketingExpensesName(): Text[100]
    begin
        exit(TotalOtherMarketingExpensesTok);
    end;

    procedure SalesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesExpensesName()));
    end;

    procedure SalesExpensesName(): Text[100]
    begin
        exit(SalesExpensesTok);
    end;

    procedure CreditCardCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditCardChargesName()));
    end;

    procedure CreditCardChargesName(): Text[100]
    begin
        exit(CreditCardChargesTok);
    end;

    procedure BusinessEntertainingDeductible(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessEntertainingDeductibleName()));
    end;

    procedure BusinessEntertainingDeductibleName(): Text[100]
    begin
        exit(BusinessEntertainingDeductibleTok);
    end;

    procedure BusinessEntertainingNonDeductible(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessEntertainingNonDeductibleName()));
    end;

    procedure BusinessEntertainingNonDeductibleName(): Text[100]
    begin
        exit(BusinessEntertainingNonDeductibleTok);
    end;

    procedure TotalSalesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesExpensesName()));
    end;

    procedure TotalSalesExpensesName(): Text[100]
    begin
        exit(TotalSalesExpensesTok);
    end;

    procedure TotalMarketingandSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMarketingandSalesName()));
    end;

    procedure TotalMarketingandSalesName(): Text[100]
    begin
        exit(TotalMarketingandSalesTok);
    end;

    procedure OfficeExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeExpensesName()));
    end;

    procedure OfficeExpensesName(): Text[100]
    begin
        exit(OfficeExpensesTok);
    end;

    procedure PhoneServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PhoneServicesName()));
    end;

    procedure PhoneServicesName(): Text[100]
    begin
        exit(PhoneServicesTok);
    end;

    procedure DataServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DataServicesName()));
    end;

    procedure DataServicesName(): Text[100]
    begin
        exit(DataServicesTok);
    end;

    procedure PostalFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostalFeesName()));
    end;

    procedure PostalFeesName(): Text[100]
    begin
        exit(PostalFeesTok);
    end;

    procedure ConsumableExpensibleHardware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumableExpensibleHardwareName()));
    end;

    procedure ConsumableExpensibleHardwareName(): Text[100]
    begin
        exit(ConsumableExpensibleHardwareTok);
    end;

    procedure SoftwareandSubscriptionFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SoftwareandSubscriptionFeesName()));
    end;

    procedure SoftwareandSubscriptionFeesName(): Text[100]
    begin
        exit(SoftwareandSubscriptionFeesTok);
    end;

    procedure TotalOfficeExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOfficeExpensesName()));
    end;

    procedure TotalOfficeExpensesName(): Text[100]
    begin
        exit(TotalOfficeExpensesTok);
    end;

    procedure InsurancesandRisks(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesandRisksName()));
    end;

    procedure InsurancesandRisksName(): Text[100]
    begin
        exit(InsurancesandRisksTok);
    end;

    procedure CorporateInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CorporateInsuranceName()));
    end;

    procedure CorporateInsuranceName(): Text[100]
    begin
        exit(CorporateInsuranceTok);
    end;

    procedure DamagesPaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DamagesPaidName()));
    end;

    procedure DamagesPaidName(): Text[100]
    begin
        exit(DamagesPaidTok);
    end;

    procedure BadDebtLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BadDebtLossesName()));
    end;

    procedure BadDebtLossesName(): Text[100]
    begin
        exit(BadDebtLossesTok);
    end;

    procedure SecurityServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecurityServicesName()));
    end;

    procedure SecurityServicesName(): Text[100]
    begin
        exit(SecurityServicesTok);
    end;

    procedure OtherRiskExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherRiskExpensesName()));
    end;

    procedure OtherRiskExpensesName(): Text[100]
    begin
        exit(OtherRiskExpensesTok);
    end;

    procedure TotalInsurancesandRisks(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInsurancesandRisksName()));
    end;

    procedure TotalInsurancesandRisksName(): Text[100]
    begin
        exit(TotalInsurancesandRisksTok);
    end;

    procedure ManagementandAdmin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementandAdminName()));
    end;

    procedure ManagementandAdminName(): Text[100]
    begin
        exit(ManagementandAdminTok);
    end;

    procedure Management(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementName()));
    end;

    procedure ManagementName(): Text[100]
    begin
        exit(ManagementTok);
    end;

    procedure RemunerationtoDirectors(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RemunerationtoDirectorsName()));
    end;

    procedure RemunerationtoDirectorsName(): Text[100]
    begin
        exit(RemunerationtoDirectorsTok);
    end;

    procedure ManagementFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementFeesName()));
    end;

    procedure ManagementFeesName(): Text[100]
    begin
        exit(ManagementFeesTok);
    end;

    procedure AnnualInterrimReports(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnnualInterrimReportsName()));
    end;

    procedure AnnualInterrimReportsName(): Text[100]
    begin
        exit(AnnualInterrimReportsTok);
    end;

    procedure AnnualGeneralMeeting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnnualGeneralMeetingName()));
    end;

    procedure AnnualGeneralMeetingName(): Text[100]
    begin
        exit(AnnualGeneralMeetingTok);
    end;

    procedure AuditandAuditServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuditandAuditServicesName()));
    end;

    procedure AuditandAuditServicesName(): Text[100]
    begin
        exit(AuditandAuditServicesTok);
    end;

    procedure TaxAdvisoryServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxAdvisoryServicesName()));
    end;

    procedure TaxAdvisoryServicesName(): Text[100]
    begin
        exit(TaxAdvisoryServicesTok);
    end;

    procedure TotalManagementFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalManagementFeesName()));
    end;

    procedure TotalManagementFeesName(): Text[100]
    begin
        exit(TotalManagementFeesTok);
    end;

    procedure TotalManagementandAdmin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalManagementandAdminName()));
    end;

    procedure TotalManagementandAdminName(): Text[100]
    begin
        exit(TotalManagementandAdminTok);
    end;

    procedure BankingandInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankingandInterestName()));
    end;

    procedure BankingandInterestName(): Text[100]
    begin
        exit(BankingandInterestTok);
    end;

    procedure BankingFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankingFeesName()));
    end;

    procedure BankingFeesName(): Text[100]
    begin
        exit(BankingFeesTok);
    end;

    procedure PayableInvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayableInvoiceRoundingName()));
    end;

    procedure PayableInvoiceRoundingName(): Text[100]
    begin
        exit(PayableInvoiceRoundingTok);
    end;

    procedure TotalBankingandInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBankingandInterestName()));
    end;

    procedure TotalBankingandInterestName(): Text[100]
    begin
        exit(TotalBankingandInterestTok);
    end;

    procedure ExternalServicesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExternalServicesExpensesName()));
    end;

    procedure ExternalServicesExpensesName(): Text[100]
    begin
        exit(ExternalServicesExpensesTok);
    end;

    procedure ExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExternalServicesName()));
    end;

    procedure ExternalServicesName(): Text[100]
    begin
        exit(ExternalServicesTok);
    end;

    procedure AccountingServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountingServicesName()));
    end;

    procedure AccountingServicesName(): Text[100]
    begin
        exit(AccountingServicesTok);
    end;

    procedure ITServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ITServicesName()));
    end;

    procedure ITServicesName(): Text[100]
    begin
        exit(ITServicesTok);
    end;

    procedure MediaServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MediaServicesName()));
    end;

    procedure MediaServicesName(): Text[100]
    begin
        exit(MediaServicesTok);
    end;

    procedure ConsultingServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsultingServicesName()));
    end;

    procedure ConsultingServicesName(): Text[100]
    begin
        exit(ConsultingServicesTok);
    end;

    procedure LegalFeesandAttorneyServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LegalFeesandAttorneyServicesName()));
    end;

    procedure LegalFeesandAttorneyServicesName(): Text[100]
    begin
        exit(LegalFeesandAttorneyServicesTok);
    end;

    procedure OtherExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherExternalServicesName()));
    end;

    procedure OtherExternalServicesName(): Text[100]
    begin
        exit(OtherExternalServicesTok);
    end;

    procedure TotalExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalExternalServicesName()));
    end;

    procedure TotalExternalServicesName(): Text[100]
    begin
        exit(TotalExternalServicesTok);
    end;

    procedure OtherExternalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherExternalExpensesName()));
    end;

    procedure OtherExternalExpensesName(): Text[100]
    begin
        exit(OtherExternalExpensesTok);
    end;

    procedure LicenseFeesRoyalties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LicenseFeesRoyaltiesName()));
    end;

    procedure LicenseFeesRoyaltiesName(): Text[100]
    begin
        exit(LicenseFeesRoyaltiesTok);
    end;

    procedure TrademarksPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TrademarksPatentsName()));
    end;

    procedure TrademarksPatentsName(): Text[100]
    begin
        exit(TrademarksPatentsTok);
    end;

    procedure AssociationFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssociationFeesName()));
    end;

    procedure AssociationFeesName(): Text[100]
    begin
        exit(AssociationFeesTok);
    end;

    procedure MiscExternalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscExternalExpensesName()));
    end;

    procedure MiscExternalExpensesName(): Text[100]
    begin
        exit(MiscExternalExpensesTok);
    end;

    procedure PurchaseDiscounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseDiscountsName()));
    end;

    procedure PurchaseDiscountsName(): Text[100]
    begin
        exit(PurchaseDiscountsTok);
    end;

    procedure TotalOtherExternalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherExternalExpensesName()));
    end;

    procedure TotalOtherExternalExpensesName(): Text[100]
    begin
        exit(TotalOtherExternalExpensesTok);
    end;

    procedure TotalExternalServicesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalExternalServicesExpensesName()));
    end;

    procedure TotalExternalServicesExpensesName(): Text[100]
    begin
        exit(TotalExternalServicesExpensesTok);
    end;

    procedure Personnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonnelName()));
    end;

    procedure PersonnelName(): Text[100]
    begin
        exit(PersonnelTok);
    end;

    procedure WagesandSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesandSalariesName()));
    end;

    procedure WagesandSalariesName(): Text[100]
    begin
        exit(WagesandSalariesTok);
    end;

    procedure HourlyWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HourlyWagesName()));
    end;

    procedure HourlyWagesName(): Text[100]
    begin
        exit(HourlyWagesTok);
    end;

    procedure OvertimeWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OvertimeWagesName()));
    end;

    procedure OvertimeWagesName(): Text[100]
    begin
        exit(OvertimeWagesTok);
    end;

    procedure Bonuses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BonusesName()));
    end;

    procedure BonusesName(): Text[100]
    begin
        exit(BonusesTok);
    end;

    procedure CommissionsPaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommissionsPaidName()));
    end;

    procedure CommissionsPaidName(): Text[100]
    begin
        exit(CommissionsPaidTok);
    end;

    procedure PTOAccrued(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PTOAccruedName()));
    end;

    procedure PTOAccruedName(): Text[100]
    begin
        exit(PTOAccruedTok);
    end;

    procedure TotalWagesandSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalWagesandSalariesName()));
    end;

    procedure TotalWagesandSalariesName(): Text[100]
    begin
        exit(TotalWagesandSalariesTok);
    end;

    procedure BenefitsPension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BenefitsPensionName()));
    end;

    procedure BenefitsPensionName(): Text[100]
    begin
        exit(BenefitsPensionTok);
    end;

    procedure Benefits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BenefitsName()));
    end;

    procedure BenefitsName(): Text[100]
    begin
        exit(BenefitsTok);
    end;

    procedure TrainingCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TrainingCostsName()));
    end;

    procedure TrainingCostsName(): Text[100]
    begin
        exit(TrainingCostsTok);
    end;

    procedure HealthCareContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthCareContributionsName()));
    end;

    procedure HealthCareContributionsName(): Text[100]
    begin
        exit(HealthCareContributionsTok);
    end;

    procedure EntertainmentofPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EntertainmentofPersonnelName()));
    end;

    procedure EntertainmentofPersonnelName(): Text[100]
    begin
        exit(EntertainmentofPersonnelTok);
    end;

    procedure MandatoryClothingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MandatoryClothingExpensesName()));
    end;

    procedure MandatoryClothingExpensesName(): Text[100]
    begin
        exit(MandatoryClothingExpensesTok);
    end;

    procedure OtherCashRemunerationBenefits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCashRemunerationBenefitsName()));
    end;

    procedure OtherCashRemunerationBenefitsName(): Text[100]
    begin
        exit(OtherCashRemunerationBenefitsTok);
    end;

    procedure TotalBenefits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBenefitsName()));
    end;

    procedure TotalBenefitsName(): Text[100]
    begin
        exit(TotalBenefitsTok);
    end;

    procedure Pension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionName()));
    end;

    procedure PensionName(): Text[100]
    begin
        exit(PensionTok);
    end;

    procedure PensionFeesandRecurringCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionFeesandRecurringCostsName()));
    end;

    procedure PensionFeesandRecurringCostsName(): Text[100]
    begin
        exit(PensionFeesandRecurringCostsTok);
    end;

    procedure EmployerContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployerContributionsName()));
    end;

    procedure EmployerContributionsName(): Text[100]
    begin
        exit(EmployerContributionsTok);
    end;

    procedure TotalPension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPensionName()));
    end;

    procedure TotalPensionName(): Text[100]
    begin
        exit(TotalPensionTok);
    end;

    procedure TotalBenefitsPension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBenefitsPensionName()));
    end;

    procedure TotalBenefitsPensionName(): Text[100]
    begin
        exit(TotalBenefitsPensionTok);
    end;

    procedure InsurancesPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesPersonnelName()));
    end;

    procedure InsurancesPersonnelName(): Text[100]
    begin
        exit(InsurancesPersonnelTok);
    end;

    procedure HealthInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthInsuranceName()));
    end;

    procedure HealthInsuranceName(): Text[100]
    begin
        exit(HealthInsuranceTok);
    end;

    procedure DentalInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DentalInsuranceName()));
    end;

    procedure DentalInsuranceName(): Text[100]
    begin
        exit(DentalInsuranceTok);
    end;

    procedure WorkersCompensation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkersCompensationName()));
    end;

    procedure WorkersCompensationName(): Text[100]
    begin
        exit(WorkersCompensationTok);
    end;

    procedure LifeInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LifeInsuranceName()));
    end;

    procedure LifeInsuranceName(): Text[100]
    begin
        exit(LifeInsuranceTok);
    end;

    procedure TotalInsurancesPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInsurancesPersonnelName()));
    end;

    procedure TotalInsurancesPersonnelName(): Text[100]
    begin
        exit(TotalInsurancesPersonnelTok);
    end;

    procedure PersonnelTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonnelTaxesName()));
    end;

    procedure PersonnelTaxesName(): Text[100]
    begin
        exit(PersonnelTaxesTok);
    end;

    procedure FederalPersonnelTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FederalPersonnelTaxesName()));
    end;

    procedure FederalPersonnelTaxesName(): Text[100]
    begin
        exit(FederalPersonnelTaxesTok);
    end;

    procedure FederalWithholdingExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FederalWithholdingExpenseName()));
    end;

    procedure FederalWithholdingExpenseName(): Text[100]
    begin
        exit(FederalWithholdingExpenseTok);
    end;

    procedure FICAExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FICAExpenseName()));
    end;

    procedure FICAExpenseName(): Text[100]
    begin
        exit(FICAExpenseTok);
    end;

    procedure FUTAExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FUTAExpenseName()));
    end;

    procedure FUTAExpenseName(): Text[100]
    begin
        exit(FUTAExpenseTok);
    end;

    procedure MedicareExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MedicareExpenseName()));
    end;

    procedure MedicareExpenseName(): Text[100]
    begin
        exit(MedicareExpenseTok);
    end;

    procedure OtherFederalExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherFederalExpenseName()));
    end;

    procedure OtherFederalExpenseName(): Text[100]
    begin
        exit(OtherFederalExpenseTok);
    end;

    procedure TotalFederalPersonnelTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFederalPersonnelTaxesName()));
    end;

    procedure TotalFederalPersonnelTaxesName(): Text[100]
    begin
        exit(TotalFederalPersonnelTaxesTok);
    end;

    procedure StatePersonnelTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatePersonnelTaxesName()));
    end;

    procedure StatePersonnelTaxesName(): Text[100]
    begin
        exit(StatePersonnelTaxesTok);
    end;

    procedure StateWithholdingExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StateWithholdingExpenseName()));
    end;

    procedure StateWithholdingExpenseName(): Text[100]
    begin
        exit(StateWithholdingExpenseTok);
    end;

    procedure SUTAExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SUTAExpenseName()));
    end;

    procedure SUTAExpenseName(): Text[100]
    begin
        exit(SUTAExpenseTok);
    end;

    procedure TotalStatePersonnelTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalStatePersonnelTaxesName()));
    end;

    procedure TotalStatePersonnelTaxesName(): Text[100]
    begin
        exit(TotalStatePersonnelTaxesTok);
    end;

    procedure TotalPersonnelTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPersonnelTaxesName()));
    end;

    procedure TotalPersonnelTaxesName(): Text[100]
    begin
        exit(TotalPersonnelTaxesTok);
    end;

    procedure TotalPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPersonnelName()));
    end;

    procedure TotalPersonnelName(): Text[100]
    begin
        exit(TotalPersonnelTok);
    end;

    procedure Depreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationName()));
    end;

    procedure DepreciationName(): Text[100]
    begin
        exit(DepreciationTok);
    end;

    procedure TotalDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalDepreciationName()));
    end;

    procedure TotalDepreciationName(): Text[100]
    begin
        exit(TotalDepreciationTok);
    end;

    procedure MiscExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscExpensesName()));
    end;

    procedure MiscExpensesName(): Text[100]
    begin
        exit(MiscExpensesTok);
    end;

    procedure CurrencyLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrencyLossesName()));
    end;

    procedure CurrencyLossesName(): Text[100]
    begin
        exit(CurrencyLossesTok);
    end;

    procedure TotalMiscExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMiscExpensesName()));
    end;

    procedure TotalMiscExpensesName(): Text[100]
    begin
        exit(TotalMiscExpensesTok);
    end;

    procedure TotalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalExpensesName()));
    end;

    procedure TotalExpensesName(): Text[100]
    begin
        exit(TotalExpensesTok);
    end;

    procedure IntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleFixedAssetsName()));
    end;

    procedure IntangibleFixedAssetsName(): Text[100]
    begin
        exit(IntangibleFixedAssetsTok);
    end;

    procedure DevelopmentExpenditure(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DevelopmentExpenditureName()));
    end;

    procedure DevelopmentExpenditureName(): Text[100]
    begin
        exit(DevelopmentExpenditureTok);
    end;

    procedure TenancySiteLeaseHoldandSimilarRights(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TenancySiteLeaseHoldandSimilarRightsName()));
    end;

    procedure TenancySiteLeaseHoldandSimilarRightsName(): Text[100]
    begin
        exit(TenancySiteLeaseHoldandSimilarRightsTok);
    end;

    procedure Goodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodwillName()));
    end;

    procedure GoodwillName(): Text[100]
    begin
        exit(GoodwillTok);
    end;

    procedure AdvancedPaymentsforIntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancedPaymentsforIntangibleFixedAssetsName()));
    end;

    procedure AdvancedPaymentsforIntangibleFixedAssetsName(): Text[100]
    begin
        exit(AdvancedPaymentsforIntangibleFixedAssetsTok);
    end;

    procedure TotalIntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalIntangibleFixedAssetsName()));
    end;

    procedure TotalIntangibleFixedAssetsName(): Text[100]
    begin
        exit(TotalIntangibleFixedAssetsTok);
    end;

    procedure LandandBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandandBuildingsName()));
    end;

    procedure LandandBuildingsName(): Text[100]
    begin
        exit(LandandBuildingsTok);
    end;

    procedure Building(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BuildingName()));
    end;

    procedure BuildingName(): Text[100]
    begin
        exit(BuildingTok);
    end;

    procedure CostofImprovementstoLeasedProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofImprovementstoLeasedPropertyName()));
    end;

    procedure CostofImprovementstoLeasedPropertyName(): Text[100]
    begin
        exit(CostofImprovementstoLeasedPropertyTok);
    end;

    procedure Land(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandName()));
    end;

    procedure LandName(): Text[100]
    begin
        exit(LandTok);
    end;

    procedure TotalLandandbuilding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLandandbuildingName()));
    end;

    procedure TotalLandandbuildingName(): Text[100]
    begin
        exit(TotalLandandbuildingTok);
    end;

    procedure MachineryandEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachineryandEquipmentName()));
    end;

    procedure MachineryandEquipmentName(): Text[100]
    begin
        exit(MachineryandEquipmentTok);
    end;

    procedure EquipmentsandTools(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquipmentsandToolsName()));
    end;

    procedure EquipmentsandToolsName(): Text[100]
    begin
        exit(EquipmentsandToolsTok);
    end;

    procedure Computers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ComputersName()));
    end;

    procedure ComputersName(): Text[100]
    begin
        exit(ComputersTok);
    end;

    procedure CarsandOtherTransportEquipments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarsandOtherTransportEquipmentsName()));
    end;

    procedure CarsandOtherTransportEquipmentsName(): Text[100]
    begin
        exit(CarsandOtherTransportEquipmentsTok);
    end;

    procedure LeasedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LeasedAssetsName()));
    end;

    procedure LeasedAssetsName(): Text[100]
    begin
        exit(LeasedAssetsTok);
    end;

    procedure TotalMachineryandEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMachineryandEquipmentName()));
    end;

    procedure TotalMachineryandEquipmentName(): Text[100]
    begin
        exit(TotalMachineryandEquipmentTok);
    end;

    procedure AccumulatedDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationName()));
    end;

    procedure AccumulatedDepreciationName(): Text[100]
    begin
        exit(AccumulatedDepreciationTok);
    end;

    procedure TotalTangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTangibleAssetsName()));
    end;

    procedure TotalTangibleAssetsName(): Text[100]
    begin
        exit(TotalTangibleAssetsTok);
    end;

    procedure FinancialandFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialandFixedAssetsName()));
    end;

    procedure FinancialandFixedAssetsName(): Text[100]
    begin
        exit(FinancialandFixedAssetsTok);
    end;

    procedure LongTermReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongTermReceivablesName()));
    end;

    procedure LongTermReceivablesName(): Text[100]
    begin
        exit(LongTermReceivablesTok);
    end;

    procedure ParticipationinGroupCompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ParticipationinGroupCompaniesName()));
    end;

    procedure ParticipationinGroupCompaniesName(): Text[100]
    begin
        exit(ParticipationinGroupCompaniesTok);
    end;

    procedure LoanstoPartnersorRelatedParties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LoanstoPartnersorRelatedPartiesName()));
    end;

    procedure LoanstoPartnersorRelatedPartiesName(): Text[100]
    begin
        exit(LoanstoPartnersorRelatedPartiesTok);
    end;

    procedure DeferredTaxAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredTaxAssetsName()));
    end;

    procedure DeferredTaxAssetsName(): Text[100]
    begin
        exit(DeferredTaxAssetsTok);
    end;

    procedure OtherLongTermReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLongTermReceivablesName()));
    end;

    procedure OtherLongTermReceivablesName(): Text[100]
    begin
        exit(OtherLongTermReceivablesTok);
    end;

    procedure TotalFinancialandFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFinancialandFixedAssetsName()));
    end;

    procedure TotalFinancialandFixedAssetsName(): Text[100]
    begin
        exit(TotalFinancialandFixedAssetsTok);
    end;

    procedure InventoriesProductsandWorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoriesProductsandWorkinProgressName()));
    end;

    procedure InventoriesProductsandWorkinProgressName(): Text[100]
    begin
        exit(InventoriesProductsandWorkinProgressTok);
    end;

    procedure SuppliesandConsumables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SuppliesandConsumablesName()));
    end;

    procedure SuppliesandConsumablesName(): Text[100]
    begin
        exit(SuppliesandConsumablesTok);
    end;

    procedure ProductsinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProductsinProgressName()));
    end;

    procedure ProductsinProgressName(): Text[100]
    begin
        exit(ProductsinProgressTok);
    end;

    procedure FinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedGoodsName()));
    end;

    procedure FinishedGoodsName(): Text[100]
    begin
        exit(FinishedGoodsTok);
    end;

    procedure GoodsforResale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsforResaleName()));
    end;

    procedure GoodsforResaleName(): Text[100]
    begin
        exit(GoodsforResaleTok);
    end;

    procedure AdvancedPaymentsforGoodsandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancedPaymentsforGoodsandServicesName()));
    end;

    procedure AdvancedPaymentsforGoodsandServicesName(): Text[100]
    begin
        exit(AdvancedPaymentsforGoodsandServicesTok);
    end;

    procedure OtherInventoryItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherInventoryItemsName()));
    end;

    procedure OtherInventoryItemsName(): Text[100]
    begin
        exit(OtherInventoryItemsTok);
    end;

    procedure WorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkinProgressName()));
    end;

    procedure WorkinProgressName(): Text[100]
    begin
        exit(WorkinProgressTok);
    end;

    procedure WorkinProgressFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkinProgressFinishedGoodsName()));
    end;

    procedure WorkinProgressFinishedGoodsName(): Text[100]
    begin
        exit(WorkinProgressFinishedGoodsTok);
    end;

    procedure WIPAccruedCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPAccruedCostsName()));
    end;

    procedure WIPAccruedCostsName(): Text[100]
    begin
        exit(WIPAccruedCostsTok);
    end;

    procedure WIPInvoicedSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPInvoicedSalesName()));
    end;

    procedure WIPInvoicedSalesName(): Text[100]
    begin
        exit(WIPInvoicedSalesTok);
    end;

    procedure TotalWorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalWorkinProgressName()));
    end;

    procedure TotalWorkinProgressName(): Text[100]
    begin
        exit(TotalWorkinProgressTok);
    end;

    procedure Receivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesName()));
    end;

    procedure ReceivablesName(): Text[100]
    begin
        exit(ReceivablesTok);
    end;

    procedure AccountsReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsReceivablesName()));
    end;

    procedure AccountsReceivablesName(): Text[100]
    begin
        exit(AccountsReceivablesTok);
    end;

    procedure AccountReceivableDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountReceivableDomesticName()));
    end;

    procedure AccountReceivableDomesticName(): Text[100]
    begin
        exit(AccountReceivableDomesticTok);
    end;

    procedure InvoiceRoundingName(): Text[100]
    begin
        exit(InvoiceRoundingLbl);
    end;

    procedure InvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvoiceRoundingName()));
    end;

    procedure AccountReceivableForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountReceivableForeignName()));
    end;

    procedure AccountReceivableForeignName(): Text[100]
    begin
        exit(AccountReceivableForeignTok);
    end;

    procedure ContractualReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ContractualReceivablesName()));
    end;

    procedure ContractualReceivablesName(): Text[100]
    begin
        exit(ContractualReceivablesTok);
    end;

    procedure ConsignmentReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsignmentReceivablesName()));
    end;

    procedure ConsignmentReceivablesName(): Text[100]
    begin
        exit(ConsignmentReceivablesTok);
    end;

    procedure CreditcardsandVouchersReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditcardsandVouchersReceivablesName()));
    end;

    procedure CreditcardsandVouchersReceivablesName(): Text[100]
    begin
        exit(CreditcardsandVouchersReceivablesTok);
    end;

    procedure TotalAccountReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAccountReceivablesName()));
    end;

    procedure TotalAccountReceivablesName(): Text[100]
    begin
        exit(TotalAccountReceivablesTok);
    end;

    procedure OtherCurrentReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCurrentReceivablesName()));
    end;

    procedure OtherCurrentReceivablesName(): Text[100]
    begin
        exit(OtherCurrentReceivablesTok);
    end;

    procedure CurrentReceivablefromEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentReceivablefromEmployeesName()));
    end;

    procedure CurrentReceivablefromEmployeesName(): Text[100]
    begin
        exit(CurrentReceivablefromEmployeesTok);
    end;

    procedure AccruedincomenotYetInvoiced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedincomenotYetInvoicedName()));
    end;

    procedure AccruedincomenotYetInvoicedName(): Text[100]
    begin
        exit(AccruedincomenotYetInvoicedTok);
    end;

    procedure ClearingAccountsforTaxesandCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountsforTaxesandChargesName()));
    end;

    procedure ClearingAccountsforTaxesandChargesName(): Text[100]
    begin
        exit(ClearingAccountsforTaxesandChargesTok);
    end;

    procedure TaxAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxAssetsName()));
    end;

    procedure TaxAssetsName(): Text[100]
    begin
        exit(TaxAssetsTok);
    end;

    procedure CurrentReceivablesFromGroupCompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentReceivablesFromGroupCompaniesName()));
    end;

    procedure CurrentReceivablesFromGroupCompaniesName(): Text[100]
    begin
        exit(CurrentReceivablesFromGroupCompaniesTok);
    end;

    procedure TotalOtherCurrentReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherCurrentReceivablesName()));
    end;

    procedure TotalOtherCurrentReceivablesName(): Text[100]
    begin
        exit(TotalOtherCurrentReceivablesTok);
    end;

    procedure TotalReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalReceivablesName()));
    end;

    procedure TotalReceivablesName(): Text[100]
    begin
        exit(TotalReceivablesTok);
    end;

    procedure PrepaidexpensesandAccruedIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidexpensesandAccruedIncomeName()));
    end;

    procedure PrepaidexpensesandAccruedIncomeName(): Text[100]
    begin
        exit(PrepaidexpensesandAccruedIncomeTok);
    end;

    procedure PrepaidRent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidRentName()));
    end;

    procedure PrepaidRentName(): Text[100]
    begin
        exit(PrepaidRentTok);
    end;

    procedure PrepaidInterestExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidInterestExpenseName()));
    end;

    procedure PrepaidInterestExpenseName(): Text[100]
    begin
        exit(PrepaidInterestExpenseTok);
    end;

    procedure AccruedRentalIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedRentalIncomeName()));
    end;

    procedure AccruedRentalIncomeName(): Text[100]
    begin
        exit(AccruedRentalIncomeTok);
    end;

    procedure AccruedInterestIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedInterestIncomeName()));
    end;

    procedure AccruedInterestIncomeName(): Text[100]
    begin
        exit(AccruedInterestIncomeTok);
    end;

    procedure AssetsInFormOfPrepaidExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssetsInFormOfPrepaidExpensesName()));
    end;

    procedure AssetsInFormOfPrepaidExpensesName(): Text[100]
    begin
        exit(AssetsInFormOfPrepaidExpensesTok);
    end;

    procedure OtherPrepaidExpensesAndAccruedIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherPrepaidExpensesAndAccruedIncomeName()));
    end;

    procedure OtherPrepaidExpensesAndAccruedIncomeName(): Text[100]
    begin
        exit(OtherPrepaidExpensesAndAccruedIncomeTok);
    end;

    procedure TotalPrepaidExpensesAndAccruedIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPrepaidExpensesAndAccruedIncomeName()));
    end;

    procedure TotalPrepaidExpensesAndAccruedIncomeName(): Text[100]
    begin
        exit(TotalPrepaidExpensesAndAccruedIncomeTok);
    end;

    procedure ShortTermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShortTermInvestmentsName()));
    end;

    procedure ShortTermInvestmentsName(): Text[100]
    begin
        exit(ShortTermInvestmentsTok);
    end;

    procedure ConvertibleDebtInstruments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConvertibleDebtInstrumentsName()));
    end;

    procedure ConvertibleDebtInstrumentsName(): Text[100]
    begin
        exit(ConvertibleDebtInstrumentsTok);
    end;

    procedure OtherShortTermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherShortTermInvestmentsName()));
    end;

    procedure OtherShortTermInvestmentsName(): Text[100]
    begin
        exit(OtherShortTermInvestmentsTok);
    end;

    procedure WriteDownofShortTermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownofShortTermInvestmentsName()));
    end;

    procedure WriteDownofShortTermInvestmentsName(): Text[100]
    begin
        exit(WriteDownofShortTermInvestmentsTok);
    end;

    procedure TotalShortTermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalShortTermInvestmentsName()));
    end;

    procedure TotalShortTermInvestmentsName(): Text[100]
    begin
        exit(TotalShortTermInvestmentsTok);
    end;

    procedure CashandBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashandBankName()));
    end;

    procedure CashandBankName(): Text[100]
    begin
        exit(CashandBankTok);
    end;

    procedure BusinessAccountOperatingDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessAccountOperatingDomesticName()));
    end;

    procedure BusinessAccountOperatingDomesticName(): Text[100]
    begin
        exit(BusinessAccountOperatingDomesticTok);
    end;

    procedure BusinessAccountOperatingForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessAccountOperatingForeignName()));
    end;

    procedure BusinessAccountOperatingForeignName(): Text[100]
    begin
        exit(BusinessAccountOperatingForeignTok);
    end;

    procedure OtherBankAccounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherBankAccountsName()));
    end;

    procedure OtherBankAccountsName(): Text[100]
    begin
        exit(OtherBankAccountsTok);
    end;

    procedure CertificateofDeposit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CertificateofDepositName()));
    end;

    procedure CertificateofDepositName(): Text[100]
    begin
        exit(CertificateofDepositTok);
    end;

    procedure TotalCashandBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCashandBankName()));
    end;

    procedure TotalCashandBankName(): Text[100]
    begin
        exit(TotalCashandBankTok);
    end;

    procedure Liability(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiabilityName()));
    end;

    procedure LiabilityName(): Text[100]
    begin
        exit(LiabilityTok);
    end;

    procedure BondsandDebentureLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BondsandDebentureLoansName()));
    end;

    procedure BondsandDebentureLoansName(): Text[100]
    begin
        exit(BondsandDebentureLoansTok);
    end;

    procedure ConvertiblesLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConvertiblesLoansName()));
    end;

    procedure ConvertiblesLoansName(): Text[100]
    begin
        exit(ConvertiblesLoansTok);
    end;

    procedure OtherLongTermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLongTermLiabilitiesName()));
    end;

    procedure OtherLongTermLiabilitiesName(): Text[100]
    begin
        exit(OtherLongTermLiabilitiesTok);
    end;

    procedure BankOverdraftFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankOverdraftFacilitiesName()));
    end;

    procedure BankOverdraftFacilitiesName(): Text[100]
    begin
        exit(BankOverdraftFacilitiesTok);
    end;

    procedure TotalLongTermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLongTermLiabilitiesName()));
    end;

    procedure TotalLongTermLiabilitiesName(): Text[100]
    begin
        exit(TotalLongTermLiabilitiesTok);
    end;

    procedure CurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLiabilitiesName()));
    end;

    procedure CurrentLiabilitiesName(): Text[100]
    begin
        exit(CurrentLiabilitiesTok);
    end;

    procedure AccountsPayableDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableDomesticName()));
    end;

    procedure AccountsPayableDomesticName(): Text[100]
    begin
        exit(AccountsPayableDomesticTok);
    end;

    procedure AccountsPayableForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableForeignName()));
    end;

    procedure AccountsPayableForeignName(): Text[100]
    begin
        exit(AccountsPayableForeignTok);
    end;

    procedure Advancesfromcustomers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancesfromcustomersName()));
    end;

    procedure AdvancesfromcustomersName(): Text[100]
    begin
        exit(AdvancesfromcustomersTok);
    end;

    procedure ChangeinWorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeinWorkinProgressName()));
    end;

    procedure ChangeinWorkinProgressName(): Text[100]
    begin
        exit(ChangeinWorkinProgressTok);
    end;

    procedure BankOverdraftShortTerm(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankOverdraftShortTermName()));
    end;

    procedure BankOverdraftShortTermName(): Text[100]
    begin
        exit(BankOverdraftShortTermTok);
    end;

    procedure TotalCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCurrentLiabilitiesName()));
    end;

    procedure TotalCurrentLiabilitiesName(): Text[100]
    begin
        exit(TotalCurrentLiabilitiesTok);
    end;

    procedure TaxLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxLiabilitiesName()));
    end;

    procedure TaxLiabilitiesName(): Text[100]
    begin
        exit(TaxLiabilitiesTok);
    end;

    procedure SalesTaxVATLiable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesTaxVATLiableName()));
    end;

    procedure SalesTaxVATLiableName(): Text[100]
    begin
        exit(SalesTaxLiableTok);
    end;

    procedure EstimatedIncomeTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedIncomeTaxName()));
    end;

    procedure EstimatedIncomeTaxName(): Text[100]
    begin
        exit(EstimatedIncomeTaxTok);
    end;

    procedure EstimatedPayrolltaxonPensionCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedPayrolltaxonPensionCostsName()));
    end;

    procedure EstimatedPayrolltaxonPensionCostsName(): Text[100]
    begin
        exit(EstimatedPayrolltaxonPensionCostsTok);
    end;

    procedure TotalTaxLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTaxLiabilitiesName()));
    end;

    procedure TotalTaxLiabilitiesName(): Text[100]
    begin
        exit(TotalTaxLiabilitiesTok);
    end;

    procedure PayrollLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollLiabilitiesName()));
    end;

    procedure PayrollLiabilitiesName(): Text[100]
    begin
        exit(PayrollLiabilitiesTok);
    end;

    procedure EmployeesWithholdingTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesWithholdingTaxesName()));
    end;

    procedure EmployeesWithholdingTaxesName(): Text[100]
    begin
        exit(EmployeesWithholdingTaxesTok);
    end;

    procedure StatutorySocialsecurityContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutorySocialsecurityContributionsName()));
    end;

    procedure StatutorySocialsecurityContributionsName(): Text[100]
    begin
        exit(StatutorySocialsecurityContributionsTok);
    end;

    procedure ContractualSocialSecurityContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ContractualSocialSecurityContributionsName()));
    end;

    procedure ContractualSocialSecurityContributionsName(): Text[100]
    begin
        exit(ContractualSocialSecurityContributionsTok);
    end;

    procedure AttachmentsofEarning(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AttachmentsofEarningName()));
    end;

    procedure AttachmentsofEarningName(): Text[100]
    begin
        exit(AttachmentsofEarningTok);
    end;

    procedure HolidayPayfund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HolidayPayfundName()));
    end;

    procedure HolidayPayfundName(): Text[100]
    begin
        exit(HolidayPayfundTok);
    end;

    procedure OtherSalaryWageDeductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherSalaryWageDeductionsName()));
    end;

    procedure OtherSalaryWageDeductionsName(): Text[100]
    begin
        exit(OtherSalaryWageDeductionsTok);
    end;

    procedure TotalPayrollLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPayrollLiabilitiesName()));
    end;

    procedure TotalPayrollLiabilitiesName(): Text[100]
    begin
        exit(TotalPayrollLiabilitiesTok);
    end;

    procedure OtherCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCurrentLiabilitiesName()));
    end;

    procedure OtherCurrentLiabilitiesName(): Text[100]
    begin
        exit(OtherCurrentLiabilitiesTok);
    end;

    procedure ClearingAccountforFactoringCurrentPortion(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountforFactoringCurrentPortionName()));
    end;

    procedure ClearingAccountforFactoringCurrentPortionName(): Text[100]
    begin
        exit(ClearingAccountforFactoringCurrentPortionTok);
    end;

    procedure CurrentLiabilitiestoEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLiabilitiestoEmployeesName()));
    end;

    procedure CurrentLiabilitiestoEmployeesName(): Text[100]
    begin
        exit(CurrentLiabilitiestoEmployeesTok);
    end;

    procedure ClearingAccountforThirdParty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountforThirdPartyName()));
    end;

    procedure ClearingAccountforThirdPartyName(): Text[100]
    begin
        exit(ClearingAccountforThirdPartyTok);
    end;

    procedure CurrentLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLoansName()));
    end;

    procedure CurrentLoansName(): Text[100]
    begin
        exit(CurrentLoansTok);
    end;

    procedure LiabilitiesGrantsReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiabilitiesGrantsReceivedName()));
    end;

    procedure LiabilitiesGrantsReceivedName(): Text[100]
    begin
        exit(LiabilitiesGrantsReceivedTok);
    end;

    procedure TotalOtherCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherCurrentLiabilitiesName()));
    end;

    procedure TotalOtherCurrentLiabilitiesName(): Text[100]
    begin
        exit(TotalOtherCurrentLiabilitiesTok);
    end;

    procedure AccruedExpensesandDeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedExpensesandDeferredIncomeName()));
    end;

    procedure AccruedExpensesandDeferredIncomeName(): Text[100]
    begin
        exit(AccruedExpensesandDeferredIncomeTok);
    end;

    procedure AccruedWagesSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedWagesSalariesName()));
    end;

    procedure AccruedWagesSalariesName(): Text[100]
    begin
        exit(AccruedWagesSalariesTok);
    end;

    procedure AccruedHolidayPay(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedHolidayPayName()));
    end;

    procedure AccruedHolidayPayName(): Text[100]
    begin
        exit(AccruedHolidayPayTok);
    end;

    procedure AccruedPensionCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedPensionCostsName()));
    end;

    procedure AccruedPensionCostsName(): Text[100]
    begin
        exit(AccruedPensionCostsTok);
    end;

    procedure AccruedInterestExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedInterestExpenseName()));
    end;

    procedure AccruedInterestExpenseName(): Text[100]
    begin
        exit(AccruedInterestExpenseTok);
    end;

    procedure DeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredIncomeName()));
    end;

    procedure DeferredIncomeName(): Text[100]
    begin
        exit(DeferredIncomeTok);
    end;

    procedure AccruedContractualCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedContractualCostsName()));
    end;

    procedure AccruedContractualCostsName(): Text[100]
    begin
        exit(AccruedContractualCostsTok);
    end;

    procedure OtherAccruedExpensesandDeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherAccruedExpensesandDeferredIncomeName()));
    end;

    procedure OtherAccruedExpensesandDeferredIncomeName(): Text[100]
    begin
        exit(OtherAccruedExpensesandDeferredIncomeTok);
    end;

    procedure TotalAccruedExpensesandDeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAccruedExpensesandDeferredIncomeName()));
    end;

    procedure TotalAccruedExpensesandDeferredIncomeName(): Text[100]
    begin
        exit(TotalAccruedExpensesandDeferredIncomeTok);
    end;

    procedure Equity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityName()));
    end;

    procedure EquityName(): Text[100]
    begin
        exit(EquityTok);
    end;

    procedure EquityPartner(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityPartnerName()));
    end;

    procedure EquityPartnerName(): Text[100]
    begin
        exit(EquityPartnerTok);
    end;

    procedure NetResults(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetResultsName()));
    end;

    procedure NetResultsName(): Text[100]
    begin
        exit(NetResultsTok);
    end;

    procedure RestrictedEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RestrictedEquityName()));
    end;

    procedure RestrictedEquityName(): Text[100]
    begin
        exit(RestrictedEquityTok);
    end;

    procedure ShareCapital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShareCapitalName()));
    end;

    procedure ShareCapitalName(): Text[100]
    begin
        exit(ShareCapitalTok);
    end;

    procedure NonRestrictedEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonRestrictedEquityName()));
    end;

    procedure NonRestrictedEquityName(): Text[100]
    begin
        exit(NonRestrictedEquityTok);
    end;

    procedure ProfitorLossFromthePreviousYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitorLossFromthePreviousYearName()));
    end;

    procedure ProfitorLossFromthePreviousYearName(): Text[100]
    begin
        exit(ProfitorLossFromthePreviousYearTok);
    end;

    procedure ResultsfortheFinancialYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResultsfortheFinancialYearName()));
    end;

    procedure ResultsfortheFinancialYearName(): Text[100]
    begin
        exit(ResultsfortheFinancialYearTok);
    end;

    procedure DistributionstoShareholders(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DistributionstoShareholdersName()));
    end;

    procedure DistributionstoShareholdersName(): Text[100]
    begin
        exit(DistributionstoShareholdersTok);
    end;

    procedure TotalEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalEquityName()));
    end;

    procedure TotalEquityName(): Text[100]
    begin
        exit(TotalEquityTok);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SaleofRawMaterialsLbl: Label 'Sale of Raw Materials', MaxLength = 100;
        SaleofFinishedGoodsLbl: Label 'Sale of Finished Goods', MaxLength = 100;
        SalesofGoodsLbl: Label 'Sales of Goods', MaxLength = 100;
        IncomeLbl: Label 'Income', MaxLength = 100;
        TotalSalesofGoodsTok: Label 'Total, Sales of Goods', MaxLength = 100;
        SaleofResourcesTok: Label 'Sale of Resources', MaxLength = 100;
        SaleofSubcontractingTok: Label 'Sale of Subcontracting', MaxLength = 100;
        TotalSalesofResourcesTok: Label 'Total, Sales of Resources', MaxLength = 100;
        AdditionalRevenueTok: Label 'Additional Revenue', MaxLength = 100;
        IncomeFromSecuritiesTok: Label 'Income from securities', MaxLength = 100;
        ManagementFeeRevenueTok: Label 'Management Fee Revenue', MaxLength = 100;
        CurrencyGainsTok: Label 'Currency Gains', MaxLength = 100;
        OtherIncidentalRevenueTok: Label 'Other Incidental Revenue', MaxLength = 100;
        TotalAdditionalRevenueTok: Label 'Total, Additional Revenue', MaxLength = 100;
        JobsandServicesTok: Label 'Jobs and Services', MaxLength = 100;
        JobSalesAppliedTok: Label 'Job Sales Applied', MaxLength = 100;
        SalesofServiceContractsTok: Label 'Sales of Service Contracts', MaxLength = 100;
        TotalJobsandServicesTok: Label 'Total, Jobs and Services', MaxLength = 100;
        RevenueReductionsTok: Label 'Revenue Reductions', MaxLength = 100;
        DiscountsandAllowancesTok: Label 'Discounts and Allowances', MaxLength = 100;
        InvoiceRoundingTok: Label 'Invoice Rounding', MaxLength = 100;
        PaymentToleranceTok: Label 'Payment Tolerance', MaxLength = 100;
        SalesReturnsTok: Label 'Sales Returns', MaxLength = 100;
        TotalRevenueReductionsTok: Label 'Total, Revenue Reductions', MaxLength = 100;
        TotalIncomeTok: Label 'TOTAL INCOME', MaxLength = 100;
        CostofGoodsSoldTok: Label 'COST OF GOODS SOLD', MaxLength = 100;
        CostofGoodsTok: Label 'Cost of Goods', MaxLength = 100;
        CostofMaterialsProjectsTok: Label 'Cost of Materials, Projects', MaxLength = 100;
        TotalCostofGoodsTok: Label 'Total, Cost of Goods', MaxLength = 100;
        CostofResourcesandServicesTok: Label 'Cost of Resources and Services', MaxLength = 100;
        CostofLaborTok: Label 'Cost of Labor', MaxLength = 100;
        CostofLaborProjectsTok: Label 'Cost of Labor, Projects', MaxLength = 100;
        CostofLaborWarrantyContractTok: Label 'Cost of Labor, Warranty/Contract', MaxLength = 100;
        TotalCostofResourcesTok: Label 'Total, Cost of Resources', MaxLength = 100;
        SubcontractedWorkTok: Label 'Subcontracted work', MaxLength = 100;
        CostofVariancesTok: Label 'Cost of Variances', MaxLength = 100;
        TotalCostofGoodsSoldTok: Label 'TOTAL COST OF GOODS SOLD', MaxLength = 100;
        ExpenseTok: Label 'EXPENSES', MaxLength = 100;
        FacilityExpensesTok: Label 'Facility Expenses', MaxLength = 100;
        RentalFacilitiesTok: Label 'Rental Facilities', MaxLength = 100;
        RentLeasesTok: Label 'Rent / Leases', MaxLength = 100;
        ElectricityforRentalTok: Label 'Electricity for Rental', MaxLength = 100;
        HeatingforRentalTok: Label 'Heating for Rental', MaxLength = 100;
        WaterandSewerageforRentalTok: Label 'Water and Sewerage for Rental', MaxLength = 100;
        CleaningandWasteforRentalTok: Label 'Cleaning and Waste for Rental', MaxLength = 100;
        RepairsandMaintenanceforRentalTok: Label 'Repairs and Maintenance for Rental', MaxLength = 100;
        InsurancesRentalTok: Label 'Insurances, Rental', MaxLength = 100;
        OtherRentalExpensesTok: Label 'Other Rental Expenses', MaxLength = 100;
        TotalRentalFacilitiesTok: Label 'Total, Rental Facilities', MaxLength = 100;
        PropertyExpensesTok: Label 'Property Expenses', MaxLength = 100;
        SiteFeesLeasesTok: Label 'Site Fees / Leases', MaxLength = 100;
        ElectricityforPropertyTok: Label 'Electricity for Property', MaxLength = 100;
        HeatingforPropertyTok: Label 'Heating for Property', MaxLength = 100;
        WaterandSewerageforPropertyTok: Label 'Water and Sewerage for Property', MaxLength = 100;
        CleaningandWasteforPropertyTok: Label 'Cleaning and Waste for Property', MaxLength = 100;
        RepairsandMaintenanceforPropertyTok: Label 'Repairs and Maintenance for Property', MaxLength = 100;
        InsurancesPropertyTok: Label 'Insurances, Property', MaxLength = 100;
        OtherPropertyExpensesTok: Label 'Other Property Expenses', MaxLength = 100;
        TotalPropertyExpensesTok: Label 'Total, Property Expenses', MaxLength = 100;
        TotalFacilityExpensesTok: Label 'Total, Facility Expenses', MaxLength = 100;
        FixedAssetsLeasesTok: Label 'Fixed Assets Leases', MaxLength = 100;
        HireofMachineryTok: Label 'Hire of machinery', MaxLength = 100;
        HireofComputersTok: Label 'Hire of computers', MaxLength = 100;
        HireofOtherFixedAssetsTok: Label 'Hire of other fixed assets', MaxLength = 100;
        TotalFixedAssetLeasesTok: Label 'Total, Fixed Asset Leases', MaxLength = 100;
        LogisticsExpensesTok: Label 'Logistics Expenses', MaxLength = 100;
        PassengerCarCostsTok: Label 'Passenger Car Costs', MaxLength = 100;
        TruckCostsTok: Label 'Truck Costs', MaxLength = 100;
        OtherVehicleExpensesTok: Label 'Other vehicle expenses', MaxLength = 100;
        TotalVehicleExpensesTok: Label 'Total, Vehicle Expenses', MaxLength = 100;
        FreightCostsTok: Label 'Freight Costs', MaxLength = 100;
        FreightFeesForGoodsTok: Label 'Freight fees for goods', MaxLength = 100;
        CustomsandForwardingTok: Label 'Customs and forwarding', MaxLength = 100;
        FreightFeesProjectsTok: Label 'Freight fees, projects', MaxLength = 100;
        TotalFreightCostsTok: Label 'Total, Freight Costs', MaxLength = 100;
        TravelExpensesTok: Label 'Travel Expenses', MaxLength = 100;
        TicketsTok: Label 'Tickets', MaxLength = 100;
        RentalVehiclesTok: Label 'Rental vehicles', MaxLength = 100;
        BoardandLodgingTok: Label 'Board and lodging', MaxLength = 100;
        OtherTravelExpensesTok: Label 'Other travel expenses', MaxLength = 100;
        TotalTravelExpensesTok: Label 'Total, Travel Expenses', MaxLength = 100;
        TotalLogisticsExpensesTok: Label 'Total, Logistics Expenses', MaxLength = 100;
        MarketingandSalesTok: Label 'Marketing and Sales', MaxLength = 100;
        AdvertisementDevelopmentTok: Label 'Advertisement Development', MaxLength = 100;
        OutdoorandTransportationAdsTok: Label 'Outdoor and Transportation Ads', MaxLength = 100;
        AdMatterandDirectMailingsTok: Label 'Ad matter and direct mailings', MaxLength = 100;
        ConferenceExhibitionSponsorshipTok: Label 'Conference/Exhibition Sponsorship', MaxLength = 100;
        SamplesContestsGiftsTok: Label 'Samples, contests, gifts', MaxLength = 100;
        FilmTVRadioInternetAdsTok: Label 'Film, TV, radio, internet ads', MaxLength = 100;
        PRandAgencyFeesTok: Label 'PR and Agency Fees', MaxLength = 100;
        OtherAdvertisingFeesTok: Label 'Other advertising fees', MaxLength = 100;
        TotalAdvertisingTok: Label 'Total, Advertising', MaxLength = 100;
        OtherMarketingExpensesTok: Label 'Other Marketing Expenses', MaxLength = 100;
        CatalogsPriceListsTok: Label 'Catalogs, price lists', MaxLength = 100;
        TradePublicationsTok: Label 'Trade Publications', MaxLength = 100;
        TotalOtherMarketingExpensesTok: Label 'Total, Other Marketing Expenses', MaxLength = 100;
        SalesExpensesTok: Label 'Sales Expenses', MaxLength = 100;
        CreditCardChargesTok: Label 'Credit Card Charges', MaxLength = 100;
        BusinessEntertainingDeductibleTok: Label 'Business Entertaining, deductible', MaxLength = 100;
        BusinessEntertainingNonDeductibleTok: Label 'Business Entertaining, nondeductible', MaxLength = 100;
        TotalSalesExpensesTok: Label 'Total, Sales Expenses', MaxLength = 100;
        TotalMarketingandSalesTok: Label 'Total, Marketing and Sales', MaxLength = 100;
        OfficeExpensesTok: Label 'Office Expenses', MaxLength = 100;
        PhoneServicesTok: Label 'Phone Services', MaxLength = 100;
        DataservicesTok: Label 'Data services', MaxLength = 100;
        PostalFeesTok: Label 'Postal fees', MaxLength = 100;
        ConsumableExpensibleHardwareTok: Label 'Consumable/Expensible hardware', MaxLength = 100;
        SoftwareandSubscriptionFeesTok: Label 'Software and subscription fees', MaxLength = 100;
        TotalOfficeExpensesTok: Label 'Total, Office Expenses', MaxLength = 100;
        InsurancesandRisksTok: Label 'Insurances and Risks', MaxLength = 100;
        CorporateInsuranceTok: Label 'Corporate Insurance', MaxLength = 100;
        DamagesPaidTok: Label 'Damages Paid', MaxLength = 100;
        BadDebtLossesTok: Label 'Bad Debt Losses', MaxLength = 100;
        SecurityServicesTok: Label 'Security services', MaxLength = 100;
        OtherRiskExpensesTok: Label 'Other risk expenses', MaxLength = 100;
        TotalInsurancesandRisksTok: Label 'Total, Insurances and Risks', MaxLength = 100;
        ManagementandAdminTok: Label 'Management and Admin', MaxLength = 100;
        ManagementTok: Label 'Management', MaxLength = 100;
        RemunerationtoDirectorsTok: Label 'Remuneration to Directors', MaxLength = 100;
        ManagementFeesTok: Label 'Management Fees', MaxLength = 100;
        AnnualInterrimReportsTok: Label 'Annual/interrim Reports', MaxLength = 100;
        AnnualGeneralMeetingTok: Label 'Annual/general meeting', MaxLength = 100;
        AuditandAuditServicesTok: Label 'Audit and Audit Services', MaxLength = 100;
        TaxAdvisoryServicesTok: Label 'Tax advisory Services', MaxLength = 100;
        TotalManagementFeesTok: Label 'Total, Management Fees', MaxLength = 100;
        TotalManagementandAdminTok: Label 'Total, Management and Admin', MaxLength = 100;
        BankingandInterestTok: Label 'Banking and Interest', MaxLength = 100;
        BankingFeesTok: Label 'Banking fees', MaxLength = 100;
        PayableInvoiceRoundingTok: Label 'Payable Invoice Rounding', MaxLength = 100;
        TotalBankingandInterestTok: Label 'Total, Banking and Interest', MaxLength = 100;
        ExternalServicesExpensesTok: Label 'External Services/Expenses', MaxLength = 100;
        ExternalServicesTok: Label 'External Services', MaxLength = 100;
        AccountingServicesTok: Label 'Accounting Services', MaxLength = 100;
        ITServicesTok: Label 'IT Services', MaxLength = 100;
        MediaServicesTok: Label 'Media Services', MaxLength = 100;
        ConsultingServicesTok: Label 'Consulting Services', MaxLength = 100;
        LegalFeesandAttorneyServicesTok: Label 'Legal Fees and Attorney Services', MaxLength = 100;
        OtherExternalServicesTok: Label 'Other External Services', MaxLength = 100;
        TotalExternalServicesTok: Label 'Total, External Services', MaxLength = 100;
        OtherExternalExpensesTok: Label 'Other External Expenses', MaxLength = 100;
        LicenseFeesRoyaltiesTok: Label 'License Fees/Royalties', MaxLength = 100;
        TrademarksPatentsTok: Label 'Trademarks/Patents', MaxLength = 100;
        AssociationFeesTok: Label 'Association Fees', MaxLength = 100;
        MiscExternalExpensesTok: Label 'Misc. external expenses', MaxLength = 100;
        PurchaseDiscountsTok: Label 'Purchase Discounts', MaxLength = 100;
        TotalOtherExternalExpensesTok: Label 'Total, Other External Expenses', MaxLength = 100;
        TotalExternalServicesExpensesTok: Label 'Total, External Services/Expenses', MaxLength = 100;
        PersonnelTok: Label 'Personnel', MaxLength = 100;
        WagesandSalariesTok: Label 'Wages and Salaries', MaxLength = 100;
        HourlyWagesTok: Label 'Hourly Wages', MaxLength = 100;
        OvertimeWagesTok: Label 'Overtime Wages', MaxLength = 100;
        BonusesTok: Label 'Bonuses', MaxLength = 100;
        CommissionsPaidTok: Label 'Commissions Paid', MaxLength = 100;
        PTOAccruedTok: Label 'PTO Accrued', MaxLength = 100;
        TotalWagesandSalariesTok: Label 'Total, Wages and Salaries', MaxLength = 100;
        BenefitsPensionTok: Label 'Benefits/Pension', MaxLength = 100;
        BenefitsTok: Label 'Benefits', MaxLength = 100;
        TrainingCostsTok: Label 'Training Costs', MaxLength = 100;
        HealthCareContributionsTok: Label 'Health Care Contributions', MaxLength = 100;
        EntertainmentofPersonnelTok: Label 'Entertainment of personnel', MaxLength = 100;
        MandatoryClothingExpensesTok: Label 'Mandatory clothing expenses', MaxLength = 100;
        OtherCashRemunerationBenefitsTok: Label 'Other cash/remuneration benefits', MaxLength = 100;
        TotalBenefitsTok: Label 'Total, Benefits', MaxLength = 100;
        PensionTok: Label 'Pension', MaxLength = 100;
        PensionFeesandRecurringCostsTok: Label 'Pension fees and recurring costs', MaxLength = 100;
        EmployerContributionsTok: Label 'Employer Contributions', MaxLength = 100;
        TotalPensionTok: Label 'Total, Pension', MaxLength = 100;
        TotalBenefitsPensionTok: Label 'Total, Benefits/Pension', MaxLength = 100;
        InsurancesPersonnelTok: Label 'Insurances, Personnel', MaxLength = 100;
        HealthInsuranceTok: Label 'Health Insurance', MaxLength = 100;
        DentalInsuranceTok: Label 'Dental Insurance', MaxLength = 100;
        WorkersCompensationTok: Label 'Worker''s Compensation', MaxLength = 100;
        LifeInsuranceTok: Label 'Life Insurance', MaxLength = 100;
        TotalInsurancesPersonnelTok: Label 'Total, Insurances, Personnel', MaxLength = 100;
        PersonnelTaxesTok: Label 'Personnel Taxes', MaxLength = 100;
        FederalPersonnelTaxesTok: Label 'Federal Personnel Taxes', MaxLength = 100;
        FederalWithholdingExpenseTok: Label 'Federal Withholding Expense', MaxLength = 100;
        FICAExpenseTok: Label 'FICA Expense', MaxLength = 100;
        FUTAExpenseTok: Label 'FUTA Expense', MaxLength = 100;
        MedicareExpenseTok: Label 'Medicare Expense', MaxLength = 100;
        OtherFederalExpenseTok: Label 'Other Federal Expense', MaxLength = 100;
        TotalFederalPersonnelTaxesTok: Label 'Total, Federal Personnel Taxes', MaxLength = 100;
        StatePersonnelTaxesTok: Label 'State Personnel Taxes', MaxLength = 100;
        StateWithholdingExpenseTok: Label 'State Withholding Expense', MaxLength = 100;
        SUTAExpenseTok: Label 'SUTA Expense', MaxLength = 100;
        TotalStatePersonnelTaxesTok: Label 'Total, State Personnel Taxes', MaxLength = 100;
        TotalPersonnelTaxesTok: Label 'Total, Personnel Taxes', MaxLength = 100;
        TotalPersonnelTok: Label 'Total, Personnel', MaxLength = 100;
        DepreciationTok: Label 'Depreciation', MaxLength = 100;
        TotalDepreciationTok: Label 'Total, Depreciation', MaxLength = 100;
        MiscExpensesTok: Label 'Misc. Expenses', MaxLength = 100;
        CurrencyLossesTok: Label 'Currency Losses', MaxLength = 100;
        TotalMiscExpensesTok: Label 'Total, Misc. Expenses', MaxLength = 100;
        TotalExpensesTok: Label 'TOTAL EXPENSES', MaxLength = 100;
        InterestIncomeLbl: Label 'Interest Income', MaxLength = 100;
        CostofMaterialsLbl: Label 'Cost of Materials', MaxLength = 100;
        ResaleofGoodsLbl: Label 'Resale of Goods', MaxLength = 100;
        SalesofServiceWorkLbl: Label 'Sales of Service Work', MaxLength = 100;
        DiscountsandAllowancesLbl: Label 'Discounts and Allowances', MaxLength = 100;
        DepreciationFixedAssetsLbl: Label 'Depreciation, Fixed Assets', MaxLength = 100;
        DepreciationLandandPropertyLbl: Label 'Depreciation, Land and Property', MaxLength = 100;
        InvoiceRoundingLbl: Label 'Invoice Rounding', MaxLength = 100;
        TaxesLiableLbl: Label 'Taxes Liable', MaxLength = 100;
        IntangibleFixedAssetsTok: Label 'Intangible Fixed Assets', MaxLength = 100;
        DevelopmentExpenditureTok: Label 'Development Expenditure', MaxLength = 100;
        TenancySiteLeaseHoldandSimilarRightsTok: Label 'Tenancy, Site Leasehold and similar rights', MaxLength = 100;
        GoodwillTok: Label 'Goodwill', MaxLength = 100;
        AdvancedPaymentsforIntangibleFixedAssetsTok: Label 'Advanced Payments for Intangible Fixed Assets', MaxLength = 100;
        TotalIntangibleFixedAssetsTok: Label 'Total, Intangible Fixed Assets', MaxLength = 100;
        LandandBuildingsTok: Label 'Land and Buildings', MaxLength = 100;
        BuildingTok: Label 'Building', MaxLength = 100;
        CostofImprovementstoLeasedPropertyTok: Label 'Cost of Improvements to Leased Property', MaxLength = 100;
        LandTok: Label 'Land ', MaxLength = 100;
        TotalLandandbuildingTok: Label 'Total, Land and Building', MaxLength = 100;
        MachineryandEquipmentTok: Label 'Machinery and Equipment', MaxLength = 100;
        EquipmentsandToolsTok: Label 'Equipments and Tools', MaxLength = 100;
        ComputersTok: Label 'Computers', MaxLength = 100;
        CarsandOtherTransportEquipmentsTok: Label 'Cars and other Transport Equipments', MaxLength = 100;
        LeasedAssetsTok: Label 'Leased Assets', MaxLength = 100;
        TotalMachineryandEquipmentTok: Label 'Total, Machinery and Equipment', MaxLength = 100;
        AccumulatedDepreciationTok: Label 'Accumulated Depreciation', MaxLength = 100;
        TotalTangibleAssetsTok: Label 'Total, Tangible Assets', MaxLength = 100;
        FinancialandFixedAssetsTok: Label 'Financial and Fixed Assets', MaxLength = 100;
        LongTermReceivablesTok: Label 'Long-term Receivables ', MaxLength = 100;
        ParticipationinGroupCompaniesTok: Label 'Participation in Group Companies', MaxLength = 100;
        LoanstoPartnersorRelatedPartiesTok: Label 'Loans to Partners or related Parties', MaxLength = 100;
        DeferredTaxAssetsTok: Label 'Deferred Tax Assets', MaxLength = 100;
        OtherLongTermReceivablesTok: Label 'Other Long-term Receivables', MaxLength = 100;
        TotalFinancialandFixedAssetsTok: Label 'Total, Financial and Fixed Assets', MaxLength = 100;
        InventoriesProductsandWorkinProgressTok: Label 'Inventories, Products and work in Progress', MaxLength = 100;
        SuppliesandConsumablesTok: Label 'Supplies and Consumables', MaxLength = 100;
        ProductsinProgressTok: Label 'Products in Progress', MaxLength = 100;
        FinishedGoodsTok: Label 'Finished Goods', MaxLength = 100;
        GoodsforResaleTok: Label 'Goods for Resale', MaxLength = 100;
        AdvancedPaymentsforGoodsandServicesTok: Label 'Advanced Payments for goods and services', MaxLength = 100;
        OtherInventoryItemsTok: Label 'Other Inventory Items', MaxLength = 100;
        WorkinProgressTok: Label 'Work in Progress', MaxLength = 100;
        WorkinProgressFinishedGoodsTok: Label 'Work in Progress, Finished Goods', MaxLength = 100;
        WIPAccruedCostsTok: Label 'WIP, Accrued Costs', MaxLength = 100;
        WIPInvoicedSalesTok: Label 'WIP, Invoiced Sales', MaxLength = 100;
        TotalWorkinProgressTok: Label 'Total, Work in Progress', MaxLength = 100;
        ReceivablesTok: Label 'Receivables', MaxLength = 100;
        AccountsReceivablesTok: Label 'Accounts Receivables', MaxLength = 100;
        AccountReceivableDomesticTok: Label 'Account Receivable, Domestic', MaxLength = 100;
        AccountReceivableForeignTok: Label 'Account Receivable, Foreign', MaxLength = 100;
        ContractualReceivablesTok: Label 'Contractual Receivables', MaxLength = 100;
        ConsignmentReceivablesTok: Label 'Consignment Receivables', MaxLength = 100;
        CreditcardsandVouchersReceivablesTok: Label 'Credit cards and Vouchers Receivables', MaxLength = 100;
        TotalAccountReceivablesTok: Label 'Total, Account Receivables', MaxLength = 100;
        OtherCurrentReceivablesTok: Label 'Other Current Receivables', MaxLength = 100;
        CurrentReceivablefromEmployeesTok: Label 'Current Receivable from Employees', MaxLength = 100;
        AccruedincomenotYetInvoicedTok: Label 'Accrued income not yet invoiced', MaxLength = 100;
        ClearingAccountsforTaxesandChargesTok: Label 'Clearing Accounts for Taxes and charges', MaxLength = 100;
        TaxAssetsTok: Label 'Tax Assets', MaxLength = 100;
        CurrentReceivablesFromGroupCompaniesTok: Label 'Current Receivables from group companies', MaxLength = 100;
        TotalOtherCurrentReceivablesTok: Label 'Total, Other Current Receivables', MaxLength = 100;
        TotalReceivablesTok: Label 'Total, Receivables', MaxLength = 100;
        PrepaidexpensesandAccruedIncomeTok: Label 'Prepaid expenses and Accrued Income', MaxLength = 100;
        PrepaidRentTok: Label 'Prepaid Rent', MaxLength = 100;
        PrepaidInterestExpenseTok: Label 'Prepaid Interest expense', MaxLength = 100;
        AccruedRentalIncomeTok: Label 'Accrued Rental Income', MaxLength = 100;
        AccruedInterestIncomeTok: Label 'Accrued Interest Income', MaxLength = 100;
        AssetsInFormOfPrepaidExpensesTok: Label 'Assets in the form of prepaid expenses', MaxLength = 100;
        OtherPrepaidExpensesAndAccruedIncomeTok: Label 'Other prepaid expenses and accrued income', MaxLength = 100;
        TotalPrepaidExpensesAndAccruedIncomeTok: Label 'Total, Prepaid expenses and Accrued Income', MaxLength = 100;
        ShortTermInvestmentsTok: Label 'Short-term investments', MaxLength = 100;
        ConvertibleDebtInstrumentsTok: Label 'Convertible debt instruments', MaxLength = 100;
        OtherShortTermInvestmentsTok: Label 'Other short-term Investments', MaxLength = 100;
        WriteDownofShortTermInvestmentsTok: Label 'Write-down of Short-term investments', MaxLength = 100;
        TotalShortTermInvestmentsTok: Label 'Total, short term investments', MaxLength = 100;
        CashandBankTok: Label 'Cash and Bank', MaxLength = 100;
        BusinessAccountOperatingDomesticTok: Label 'Business account, Operating, Domestic', MaxLength = 100;
        BusinessAccountOperatingForeignTok: Label 'Business account, Operating, Foreign', MaxLength = 100;
        OtherBankAccountsTok: Label 'Other bank accounts ', MaxLength = 100;
        CertificateofDepositTok: Label 'Certificate of Deposit', MaxLength = 100;
        TotalCashandBankTok: Label 'Total, Cash and Bank', MaxLength = 100;
        LiabilityTok: Label 'Liability', MaxLength = 100;
        BondsandDebentureLoansTok: Label 'Bonds and Debenture Loans', MaxLength = 100;
        ConvertiblesLoansTok: Label 'Convertibles Loans', MaxLength = 100;
        OtherLongTermLiabilitiesTok: Label 'Other Long-term Liabilities', MaxLength = 100;
        BankOverdraftFacilitiesTok: Label 'Bank overdraft Facilities', MaxLength = 100;
        TotalLongTermLiabilitiesTok: Label 'Total, Long-term Liabilities', MaxLength = 100;
        CurrentLiabilitiesTok: Label 'Current Liabilities', MaxLength = 100;
        AccountsPayableDomesticTok: Label 'Accounts Payable, Domestic', MaxLength = 100;
        AccountsPayableForeignTok: Label 'Accounts Payable, Foreign', MaxLength = 100;
        AdvancesfromcustomersTok: Label 'Advances from customers', MaxLength = 100;
        ChangeinWorkinProgressTok: Label 'Change in Work in Progress', MaxLength = 100;
        BankOverdraftShortTermTok: Label 'Bank overdraft short-term', MaxLength = 100;
        TotalCurrentLiabilitiesTok: Label 'Total, Current Liabilities', MaxLength = 100;
        TaxLiabilitiesTok: Label 'Tax Liabilities', MaxLength = 100;
        SalesTaxLiableTok: Label 'Sales Tax Liable', MaxLength = 100;
        EstimatedIncomeTaxTok: Label 'Estimated Income Tax', MaxLength = 100;
        EstimatedPayrolltaxonPensionCostsTok: Label 'Estimated Payroll tax on Pension Costs', MaxLength = 100;
        TotalTaxLiabilitiesTok: Label 'Total, Tax Liabilities', MaxLength = 100;
        PayrollLiabilitiesTok: Label 'Payroll Liabilities', MaxLength = 100;
        EmployeesWithholdingTaxesTok: Label 'Employees Withholding Taxes', MaxLength = 100;
        StatutorySocialsecurityContributionsTok: Label 'Statutory Social security Contributions', MaxLength = 100;
        ContractualSocialSecurityContributionsTok: Label 'Contractual Social security Contributions', MaxLength = 100;
        AttachmentsofEarningTok: Label 'Attachments of Earning', MaxLength = 100;
        HolidayPayfundTok: Label 'Holiday Pay fund', MaxLength = 100;
        OtherSalaryWageDeductionsTok: Label 'Other Salary/wage Deductions', MaxLength = 100;
        TotalPayrollLiabilitiesTok: Label 'Total, Payroll Liabilities', MaxLength = 100;
        OtherCurrentLiabilitiesTok: Label 'Other Current Liabilities', MaxLength = 100;
        ClearingAccountforFactoringCurrentPortionTok: Label 'Clearing Account for Factoring, Current Portion', MaxLength = 100;
        CurrentLiabilitiestoEmployeesTok: Label 'Current Liabilities to Employees', MaxLength = 100;
        ClearingAccountforThirdPartyTok: Label 'Clearing Account for third party', MaxLength = 100;
        CurrentLoansTok: Label 'Current Loans', MaxLength = 100;
        LiabilitiesGrantsReceivedTok: Label 'Liabilities, Grants Received', MaxLength = 100;
        TotalOtherCurrentLiabilitiesTok: Label 'Total, Other Current Liabilities', MaxLength = 100;
        AccruedExpensesandDeferredIncomeTok: Label 'Accrued Expenses and Deferred Income', MaxLength = 100;
        AccruedWagesSalariesTok: Label 'Accrued wages/salaries', MaxLength = 100;
        AccruedHolidayPayTok: Label 'Accrued Holiday pay', MaxLength = 100;
        AccruedPensionCostsTok: Label 'Accrued Pension costs', MaxLength = 100;
        AccruedInterestExpenseTok: Label 'Accrued Interest Expense', MaxLength = 100;
        DeferredIncomeTok: Label 'Deferred Income', MaxLength = 100;
        AccruedContractualCostsTok: Label 'Accrued Contractual costs', MaxLength = 100;
        OtherAccruedExpensesandDeferredIncomeTok: Label 'Other Accrued Expenses and Deferred Income', MaxLength = 100;
        TotalAccruedExpensesandDeferredIncomeTok: Label 'Total, Accrued Expenses and Deferred Income', MaxLength = 100;
        EquityTok: Label 'Equity', MaxLength = 100;
        EquityPartnerTok: Label 'Equity Partner ', MaxLength = 100;
        NetResultsTok: Label 'Net Results ', MaxLength = 100;
        RestrictedEquityTok: Label 'Restricted Equity ', MaxLength = 100;
        ShareCapitalTok: Label 'Share Capital ', MaxLength = 100;
        NonRestrictedEquityTok: Label 'Non-Restricted Equity', MaxLength = 100;
        ProfitorLossFromthePreviousYearTok: Label 'Profit or loss from the previous year', MaxLength = 100;
        ResultsfortheFinancialYearTok: Label 'Results for the Financial year', MaxLength = 100;
        DistributionstoShareholdersTok: Label 'Distributions to Shareholders', MaxLength = 100;
        TotalEquityTok: Label ' Total, Equity', MaxLength = 100;
}